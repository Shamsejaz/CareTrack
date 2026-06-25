import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Simulating OCR parsing delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    const mockExtractedData = {
      medicines: [
        { name: 'Metformin', dose: '500mg', instructions: 'Twice daily' },
        { name: 'Aspirin', dose: '81mg', instructions: 'Once daily' }
      ],
      vitals: [
        { type: 'Sugar', frequency: '4 times daily' }
      ],
      rawText: "Mock extracted text from prescription (processed via Edge Function)..."
    };

    return new Response(
      JSON.stringify({ status: 'success', data: mockExtractedData }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})
