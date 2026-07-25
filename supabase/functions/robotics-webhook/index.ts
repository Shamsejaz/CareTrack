import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.6"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-robot-token',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const robotToken = req.headers.get('X-Robot-Token');
    const expectedToken = Deno.env.get('ROBOTICS_SECRET');
    
    if (!robotToken || !expectedToken || robotToken !== expectedToken) {
        return new Response(JSON.stringify({ error: 'Unauthorized robot webhook' }), { status: 401 });
    }

    const body = await req.json();
    const { task_id, status } = body;

    if (!task_id || !status) {
      return new Response(JSON.stringify({ error: 'Invalid payload' }), { status: 400 });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { error: updateError } = await supabaseAdmin
        .from('robot_tasks')
        .update({ 
            status: status,
            updated_at: new Date().toISOString()
        })
        .eq('id', task_id);
        
    if (updateError) {
        console.error('Failed to update task:', updateError);
        throw updateError;
    }

    return new Response(
        JSON.stringify({ success: true, task_id, status }), 
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
