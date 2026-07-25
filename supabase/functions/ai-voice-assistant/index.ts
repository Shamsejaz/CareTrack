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
    const { text, audio_base64 } = body;

    if (!text && !audio_base64) {
      return new Response(JSON.stringify({ error: 'Missing input (text or audio)' }), { status: 400 });
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is missing');
    }

    // Prepare content for Gemini
    const parts = [];
    if (audio_base64) {
      parts.push({
        inlineData: {
          mimeType: "audio/mp4", // generic audio type
          data: audio_base64
        }
      });
    }
    if (text) {
      parts.push({ text });
    }

    const systemInstruction = `
      You are CareTrack, a friendly, empathetic AI health assistant for older adults. 
      Your goals:
      1. Listen to the user's speech (or text).
      2. If they mention taking a medicine, logging a health event (like blood sugar or water), or taking a walk, extract the intent.
      3. If they express distress, loneliness, or ask for motivation, provide friendly, empathetic motivational support.
      
      CRITICAL COMPLIANCE RULES:
      - NEVER provide medical diagnoses.
      - NEVER act as a licensed psychiatrist or therapist.
      - If the user expresses severe medical distress (e.g. "I'm having a heart attack", "I want to hurt myself"), you must set intent to "emergency" and urge them to call 911 or their doctor immediately.
      
      Respond with ONLY a JSON object in this format (no markdown):
      {
        "intent": "log_health" | "motivational_chat" | "emergency" | "unknown",
        "log_type": "Medicine" | "Sugar" | "Walk" | "Water" | "Sleep" | null,
        "value": "extracted value (e.g., 'Metformin', '105', '30 mins') or null",
        "response_text": "Your friendly, spoken response to the user."
      }
      
      Make the response_text short, spoken-word friendly, and very empathetic.
    `;

    parts.push({ text: systemInstruction });

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=${geminiApiKey}`;
    
    const requestBody = {
      contents: [{ parts }],
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

    // If the intent is to log health, we execute it securely
    if (parsedData.intent === 'log_health' && parsedData.log_type) {
        const { error: insertError } = await supabaseClient
            .from('health_logs')
            .insert({
                patient_id: user.id,
                log_type: parsedData.log_type,
                value: parsedData.value || 'Done'
            });
            
        if (insertError) {
            console.error('Failed to insert log:', insertError);
            parsedData.response_text = "I'm sorry, I had trouble saving that to your journal. Please try again.";
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
