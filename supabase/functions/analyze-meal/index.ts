import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { GoogleGenAI } from "npm:@google/genai";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { imageBase64 } = await req.json();

    if (!imageBase64) {
      throw new Error("Missing imageBase64 in request body.");
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY environment variable is missing.");
    }

    const ai = new GoogleGenAI({ apiKey });

    const prompt = `
      Analyze this meal photo for a diabetes management app. 
      Provide the following details in a JSON format:
      {
        "mealName": "Name of the dish",
        "calories": "estimated calories with unit",
        "carbs": "estimated carbohydrates with unit",
        "healthStatus": "Healthy, Moderate, or Warning",
        "advice": "Short health tip for a diabetic patient"
      }
      Only return the JSON.
    `;

    const response = await ai.models.generateContent({
      model: 'gemini-1.5-flash',
      contents: [
        { inlineData: { data: imageBase64, mimeType: "image/jpeg" } },
        prompt
      ],
      config: {
        responseMimeType: "application/json",
      }
    });

    const text = response.text;
    if (!text) {
      throw new Error("Empty response from AI");
    }

    // In case the model wrapped it in markdown or similar
    let jsonStr = text;
    const jsonStart = text.indexOf('{');
    const jsonEnd = text.lastIndexOf('}') + 1;
    if (jsonStart !== -1 && jsonEnd !== 0) {
      jsonStr = text.substring(jsonStart, jsonEnd);
    }

    const parsedJson = JSON.parse(jsonStr);

    return new Response(
      JSON.stringify(parsedJson),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );
  } catch (error) {
    console.error("AI Analysis Error:", error);
    return new Response(
      JSON.stringify({ 
        mealName: 'Analysis Failed',
        calories: '--',
        carbs: '--',
        healthStatus: 'Unknown',
        advice: 'Could not analyze image. ' + (error instanceof Error ? error.message : 'Unknown error')
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    );
  }
});
