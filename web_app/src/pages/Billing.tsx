import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

export default function Billing() {
  const [tier, setTier] = useState<string>('free');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (user) {
      const { data } = await supabase.from('profiles').select('subscription_tier').eq('id', user.id).single();
      if (data) {
        setTier(data.subscription_tier || 'free');
      }
    }
  };

  const handleUpgrade = async (selectedTier: string) => {
    setLoading(true);
    setError('');
    
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) return;

    try {
      // In production, this URL should point to your Supabase Edge Function
      const functionUrl = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout-session`;
      
      const response = await fetch(functionUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${session.access_token}`
        },
        body: JSON.stringify({ tier: selectedTier })
      });

      const { url, error: apiError } = await response.json();
      
      if (apiError) throw new Error(apiError);
      if (url) window.location.href = url;
      
    } catch (err: any) {
      console.error(err);
      setError(err.message || 'Failed to initialize checkout');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="billing-container">
      <header className="page-header">
        <h1>Billing & Subscription</h1>
      </header>
      
      {error && <div className="error-banner">{error}</div>}
      
      <div className="current-plan">
        <h2>Current Plan: <span className="capitalize">{tier}</span></h2>
        {tier === 'free' && <p>Upgrade to unlock AI-powered insights and family features.</p>}
      </div>

      <div className="pricing-cards">
        <div className={`plan-card ${tier === 'free' ? 'active' : ''}`}>
          <h3>Free</h3>
          <p className="price">$0 <span>/ month</span></p>
          <ul>
            <li>Manual medicine tracking</li>
            <li>Basic reminders</li>
            <li>1 user</li>
          </ul>
          {tier === 'free' ? (
            <button disabled className="btn-secondary">Current Plan</button>
          ) : (
            <button disabled className="btn-secondary">Included</button>
          )}
        </div>

        <div className={`plan-card ${tier === 'premium' ? 'active' : ''}`}>
          <h3>Premium</h3>
          <p className="price">$9 <span>/ month</span></p>
          <ul>
            <li>Prescription AI & OCR</li>
            <li>Smart adaptive reminders</li>
            <li>Food photo analysis</li>
            <li>Health insights & reports</li>
          </ul>
          {tier === 'premium' ? (
            <button disabled className="btn-secondary">Current Plan</button>
          ) : (
            <button onClick={() => handleUpgrade('premium')} disabled={loading} className="btn-primary">
              {loading ? 'Processing...' : 'Upgrade to Premium'}
            </button>
          )}
        </div>

        <div className={`plan-card ${tier === 'family' ? 'active' : ''}`}>
          <h3>Family</h3>
          <p className="price">$19 <span>/ month</span></p>
          <ul>
            <li>Everything in Premium</li>
            <li>Up to 5 users</li>
            <li>Real-time caregiver alerts</li>
            <li>Remote monitoring dashboard</li>
          </ul>
          {tier === 'family' ? (
            <button disabled className="btn-secondary">Current Plan</button>
          ) : (
            <button onClick={() => handleUpgrade('family')} disabled={loading} className="btn-primary">
              {loading ? 'Processing...' : 'Upgrade to Family'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
