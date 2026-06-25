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
    const { logType, value } = await req.json();
    
    let interventionAlert = null;
    
    if (logType === 'Sugar') {
      const sugarValue = parseFloat(value);
      if (sugarValue > 180) {
        interventionAlert = { severity: 'High', message: 'Alert: High Sugar detected. Please hydrate and consult your medication schedule.' };
      } else if (sugarValue < 70) {
        interventionAlert = { severity: 'Danger', message: 'Alert: Low Sugar detected! Please consume 15g of fast-acting carbs immediately.' };
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Log analyzed by Edge Function',
        interventionAlert 
      }),
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
