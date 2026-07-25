import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.44.2";
import Stripe from "https://esm.sh/stripe@16.12.0";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
});

const cryptoProvider = Stripe.createSubtleCryptoProvider();

serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature");
  if (!signature) {
    return new Response("No signature", { status: 400 });
  }

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!webhookSecret) {
    return new Response("Webhook secret missing", { status: 500 });
  }

  const body = await req.text();
  let event: Stripe.Event;

  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret, undefined, cryptoProvider);
  } catch (err: any) {
    console.error(`Webhook signature verification failed. ${err.message}`);
    return new Response(err.message, { status: 400 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  try {
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const customerId = session.customer as string;
      const clientReferenceId = session.client_reference_id; // userId
      const tier = session.metadata?.tier || 'premium';

      if (clientReferenceId) {
        await supabase.from('profiles').update({
          stripe_customer_id: customerId,
          subscription_tier: tier,
          subscription_status: 'active'
        }).eq('id', clientReferenceId);
      }
    } else if (event.type === 'customer.subscription.updated' || event.type === 'customer.subscription.deleted') {
      const subscription = event.data.object as Stripe.Subscription;
      const customerId = subscription.customer as string;
      const status = subscription.status;
      const currentPeriodEnd = new Date(subscription.current_period_end * 1000);

      await supabase.from('profiles').update({
        subscription_status: status,
        subscription_end_date: currentPeriodEnd.toISOString(),
        ...(status !== 'active' ? { subscription_tier: 'free' } : {})
      }).eq('stripe_customer_id', customerId);
    }

    return new Response(JSON.stringify({ received: true }), { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (err: any) {
    console.error(`Error processing webhook: ${err.message}`);
    return new Response('Internal error', { status: 500 });
  }
});
