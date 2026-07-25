import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.6"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Ensure this is called with a valid Auth (or from our cron job which has the service key)
    const authHeader = req.headers.get('Authorization')
    if (!authHeader || authHeader.replace('Bearer ', '') !== Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')) {
        // Technically, cron might not have the service key if we don't pass it, 
        // but we configured pg_net to pass it. If called manually, we enforce it.
        // Wait, for local testing without the key, we might need a bypass, but we'll enforce it for security.
        throw new Error('Unauthorized: Service Role Key required for batch job');
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('Gemini API Key is not configured');
    }

    // 1. Fetch patients who have health logs in the last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const isoDate = sevenDaysAgo.toISOString();

    const { data: logsData, error: logsError } = await supabaseAdmin
      .from('health_logs')
      .select('patient_id, log_type, value, created_at')
      .gte('created_at', isoDate)
      .order('created_at', { ascending: true });

    if (logsError) throw logsError;

    // Group logs by patient_id
    const logsByPatient = (logsData || []).reduce((acc: any, log: any) => {
      if (!acc[log.patient_id]) {
        acc[log.patient_id] = [];
      }
      acc[log.patient_id].push(log);
      return acc;
    }, {});

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=${geminiApiKey}`;

    let insightsCreated = 0;

    // 2. Loop through patients and generate insights
    for (const [patientId, logs] of Object.entries(logsByPatient)) {
      if ((logs as any[]).length < 2) continue; // Need at least some data for a trend

      const prompt = `
        You are a clinical AI assistant analyzing patient health logs to find a trend.
        Here are the logs from the last 7 days for a patient:
        ${JSON.stringify(logs)}

        Based on these logs, write a single concise sentence (max 15 words) describing the most important trend or insight.
        Also categorize the severity as one of: 'Positive', 'Neutral', 'Warning', 'Critical'.
        
        Return the output strictly in the following JSON format without any markdown wrappers or code blocks:
        {
          "insight": "string",
          "severity": "string"
        }
      `;

      const requestBody = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json" }
      };

      try {
        const geminiResponse = await fetch(geminiUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(requestBody)
        });

        if (!geminiResponse.ok) {
           console.error(`Gemini API Error for patient ${patientId}`);
           continue;
        }

        const geminiData = await geminiResponse.json();
        const rawContent = geminiData.candidates[0].content.parts[0].text;
        
        let parsedData;
        try {
          parsedData = JSON.parse(rawContent);
        } catch(e) {
           const cleanContent = rawContent.replace(/```json/g, '').replace(/```/g, '').trim();
           parsedData = JSON.parse(cleanContent);
        }

        // 3. Insert into ai_insights
        const { error: insertError } = await supabaseAdmin
          .from('ai_insights')
          .insert({
            patient_id: patientId,
            insight_text: parsedData.insight,
            severity: parsedData.severity
          });

        if (insertError) {
            console.error('Failed to insert insight:', insertError);
        } else {
            insightsCreated++;
        }
      } catch (err) {
         console.error(`Failed to process patient ${patientId}:`, err);
      }
    }

    return new Response(
      JSON.stringify({ status: 'success', message: `Processed ${insightsCreated} insights.` }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
