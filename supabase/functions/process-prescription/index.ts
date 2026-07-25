import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.6"

// We can't import npm:@google/genai directly in older deno without npm specifiers, 
// but Supabase Edge Functions support npm: specifiers now.
// However, to be safe with standard APIs, we can just use the REST API 
// or standard fetch, but let's try the modern SDK.
// Since standard Google GenAI might have some Node.js dependencies, we will use the simple fetch API to Gemini to avoid bundle issues, 
// or use the older @google/generative-ai which is web-compatible.
// Wait, the context says `npm:@google/genai`. Let's use standard fetch to the Gemini REST API for maximum compatibility in Edge.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const MOCK_DRUG_INTERACTIONS = [
  { drug1: 'Aspirin', drug2: 'Ibuprofen', severity: 'High', warning: 'Increased risk of bleeding and gastrointestinal toxicity.' },
  { drug1: 'Metformin', drug2: 'Prednisone', severity: 'Moderate', warning: 'Corticosteroids can decrease the hypoglycemic effect of Metformin.' }
];

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Ensure the user is authenticated
    const authHeader = req.headers.get('Authorization')!
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(authHeader.replace('Bearer ', ''))
    
    if (authError || !user) {
      throw new Error('Unauthorized');
    }

    const { base64Image, mimeType } = await req.json()
    
    if (!base64Image) {
      throw new Error('No image provided');
    }

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('Gemini API Key is not configured');
    }

    // Call Gemini 1.5 Pro via REST API to ensure edge compatibility
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=${geminiApiKey}`;
    
    const prompt = `
      You are a clinical assistant. Extract the prescription details from this image.
      Return the output strictly in the following JSON format without any markdown wrappers or code blocks:
      {
        "medicines": [
          {
            "name": "string (e.g. Metformin)",
            "dose": "string (e.g. 500mg)",
            "timing": "string (e.g. After Breakfast)",
            "frequency": "string (e.g. Daily)"
          }
        ]
      }
    `;

    const requestBody = {
      contents: [{
        parts: [
          { text: prompt },
          {
            inline_data: {
              mime_type: mimeType || 'image/jpeg',
              data: base64Image
            }
          }
        ]
      }],
      generationConfig: {
        responseMimeType: "application/json"
      }
    };

    const geminiResponse = await fetch(geminiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(requestBody)
    });

    if (!geminiResponse.ok) {
      const err = await geminiResponse.text();
      throw new Error(`Gemini API Error: ${err}`);
    }

    const geminiData = await geminiResponse.json();
    const rawContent = geminiData.candidates[0].content.parts[0].text;
    
    let parsedData;
    try {
      parsedData = JSON.parse(rawContent);
    } catch(e) {
       // fallback if it included markdown
       const cleanContent = rawContent.replace(/```json/g, '').replace(/```/g, '').trim();
       parsedData = JSON.parse(cleanContent);
    }

    // Clinical Safety Layer (Mock Drug Interaction)
    const warnings = [];
    if (parsedData.medicines && parsedData.medicines.length > 1) {
      const drugNames = parsedData.medicines.map((m: any) => m.name.toLowerCase());
      
      for (const interaction of MOCK_DRUG_INTERACTIONS) {
        if (drugNames.includes(interaction.drug1.toLowerCase()) && 
            drugNames.includes(interaction.drug2.toLowerCase())) {
          warnings.push(interaction);
        }
      }
    }

    const responsePayload = {
      status: 'success',
      data: {
        medicines: parsedData.medicines || [],
        warnings: warnings
      }
    };

    // Audit Logging (HIPAA)
    await supabaseClient
      .from('ocr_audit_logs')
      .insert({
        patient_id: user.id,
        status: 'success',
        details: { warnings_detected: warnings.length }
      });

    return new Response(
      JSON.stringify(responsePayload),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    // Log failure
    try {
      const supabaseClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      );
      const authHeader = req.headers.get('Authorization');
      if (authHeader) {
         const { data: { user } } = await supabaseClient.auth.getUser(authHeader.replace('Bearer ', ''));
         if (user) {
            await supabaseClient.from('ocr_audit_logs').insert({
              patient_id: user.id,
              status: 'failure',
              details: { error: error.message }
            });
         }
      }
    } catch(e) {
      console.error("Failed to write audit log", e);
    }

    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
