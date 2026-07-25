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
    const body = await req.json();
    const record = body.record;

    if (!record || !record.content) {
      return new Response(JSON.stringify({ error: 'Invalid payload' }), { status: 400 });
    }

    // Ignore system messages to prevent infinite loops
    if (record.is_system) {
      return new Response(JSON.stringify({ message: 'Ignored system message' }), { status: 200 });
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is missing');
    }

    const prompt = `
      You are an AI medical mediator monitoring a care team chat.
      A user just sent this message: "${record.content}"

      Analyze the message and determine if it indicates a critical health symptom, emergency, or severe decline (e.g., falling, extreme dizziness, severe pain, unresponsiveness).
      If it IS a critical situation, provide a short, calm warning message (under 30 words) suggesting they contact emergency services or a doctor immediately if they haven't already.
      If it is NOT critical (e.g., casual conversation, minor updates), return null.

      Return ONLY JSON in this exact format, with no markdown wrappers:
      {
        "is_critical": boolean,
        "warning_message": "string or null"
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

    if (parsedData.is_critical && parsedData.warning_message) {
      // Use Service Role to insert the warning
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      );

      const { error: insertError } = await supabaseAdmin
        .from('chat_messages')
        .insert({
          sender_id: record.sender_id, // We use the sender_id so it appears in the same chat thread correctly
          receiver_id: record.receiver_id,
          content: '⚠️ AI Alert: ' + parsedData.warning_message,
          is_system: true
        });

      if (insertError) {
        console.error('Failed to insert AI warning:', insertError);
        throw insertError;
      }
      
      return new Response(JSON.stringify({ status: 'Warning inserted' }), { status: 200, headers: corsHeaders });
    }

    return new Response(JSON.stringify({ status: 'Not critical, no action taken' }), { status: 200, headers: corsHeaders });
    
  } catch (error) {
    console.error('Error processing webhook:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
})
