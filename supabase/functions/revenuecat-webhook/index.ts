import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.44.2";

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  try {
    const body = await req.json();
    const event = body.event;
    
    if (!event || !event.app_user_id) {
      return new Response('Invalid payload', { status: 400 });
    }
    
    const userId = event.app_user_id;
    const entitlement = event.entitlements ? event.entitlements[0] : null;
    
    if (event.type === 'INITIAL_PURCHASE' || event.type === 'RENEWAL') {
      const tier = entitlement === 'family' ? 'family' : 'premium';
      const expirationAtMs = event.expiration_at_ms;
      const endDate = expirationAtMs ? new Date(parseInt(expirationAtMs)).toISOString() : null;
      
      await supabase.from('profiles').update({
        revenuecat_app_user_id: userId,
        subscription_tier: tier,
        subscription_status: 'active',
        subscription_end_date: endDate
      }).eq('id', userId);
      
    } else if (event.type === 'CANCELLATION' || event.type === 'EXPIRATION') {
      await supabase.from('profiles').update({
        subscription_tier: 'free',
        subscription_status: 'canceled'
      }).eq('id', userId);
    }
    
    return new Response(JSON.stringify({ received: true }), { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (err: any) {
    console.error(`Error processing RC webhook: ${err.message}`);
    return new Response('Internal error', { status: 500 });
  }
});
