import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.6"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-device-token',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const deviceToken = req.headers.get('X-Device-Token');
    const expectedToken = Deno.env.get('IOT_DEVICE_SECRET');
    
    if (!deviceToken || !expectedToken || deviceToken !== expectedToken) {
        return new Response(JSON.stringify({ error: 'Unauthorized webhook' }), { status: 401 });
    }

    const body = await req.json();
    const { patient_id, device_type, reading_type, value } = body;

    if (!patient_id || !reading_type || !value) {
      return new Response(JSON.stringify({ error: 'Invalid payload' }), { status: 400 });
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is missing');
    }

    const prompt = `
      You are a medical anomaly detection AI.
      A smart health device just recorded the following reading for a patient:
      Device: ${device_type}
      Type: ${reading_type}
      Value: ${value}

      Determine if this reading constitutes a critical medical anomaly that requires immediate caregiver attention.
      For example: Blood Pressure of 190/120 is critical. Blood sugar of 40 is critical.
      
      CRITICAL RULE: Do NOT diagnose the patient. Only state if the reading is dangerous.

      Return ONLY JSON in this exact format (no markdown):
      {
        "is_anomaly": boolean,
        "severity": "High" | "Medium" | "Low",
        "alert_message": "A short, actionable alert message to the caregiver, or null if normal."
      }
    `;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=${geminiApiKey}`;
    
    const requestBody = {
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" }
    };

    const geminiResponse = await fetch(geminiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody)
    });

    if (!geminiResponse.ok) {
       console.error('Gemini API Error:', await geminiResponse.text());
       throw new Error('Gemini API failed');
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

    // Initialize Admin client to insert into health_logs and notifications
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 1. Always log the reading
    const { error: logError } = await supabaseAdmin
        .from('health_logs')
        .insert({
            patient_id,
            log_type: reading_type,
            value: value
        });
        
    if (logError) {
        console.error('Failed to insert log:', logError);
        throw logError;
    }

    // 2. If anomalous, trigger a notification for the caregiver
    if (parsedData.is_anomaly && parsedData.alert_message) {
        const { error: notifError } = await supabaseAdmin
            .from('notifications')
            .insert({
                patient_id,
                type: 'vital_alert',
                message: `[IoT Alert - ${device_type}] ${parsedData.alert_message}`
            });
            
        if (notifError) {
            console.error('Failed to insert notification:', notifError);
            throw notifError;
        }
    }

    return new Response(
        JSON.stringify({ 
            success: true, 
            logged: true, 
            alerted: parsedData.is_anomaly 
        }), 
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
    
  } catch (error) {
    console.error('Edge Function Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
})
