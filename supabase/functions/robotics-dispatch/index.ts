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
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Unauthorized');
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
        global: { headers: { Authorization: authHeader } }
    });

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
        throw new Error('Unauthorized or invalid JWT');
    }

    const body = await req.json();
    const { command } = body;

    if (!command) {
      return new Response(JSON.stringify({ error: 'Missing command' }), { status: 400 });
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is missing');
    }

    const prompt = `
      You are a robotics dispatch AI for an assistive home robot.
      The user just requested: "${command}"

      Determine the structured task_type that best matches their request.
      Possible task_types:
      - fetch_water
      - medication_delivery
      - mobility_assist
      - patrol
      - unknown
      
      Respond with ONLY JSON (no markdown):
      {
        "task_type": "string",
        "response_text": "Friendly confirmation to the user."
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

    if (parsedData.task_type !== 'unknown') {
        const { error: insertError } = await supabaseClient
            .from('robot_tasks')
            .insert({
                patient_id: user.id,
                task_type: parsedData.task_type,
                status: 'pending'
            });
            
        if (insertError) {
            console.error('Failed to insert robot task:', insertError);
            throw insertError;
        }
    }

    return new Response(JSON.stringify(parsedData), { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    
  } catch (error) {
    console.error('Edge Function Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
})
