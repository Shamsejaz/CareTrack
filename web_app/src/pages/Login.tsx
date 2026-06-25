import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { LogIn, ShieldAlert } from 'lucide-react';

export default function Login() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const navigate = useNavigate();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            const { error } = await supabase.auth.signInWithPassword({
                email,
                password,
            });

            if (error) throw error;
            navigate('/dashboard');
        } catch (err: any) {
            setError(err.message || 'Failed to login');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="auth-container">
            <div className="auth-card">
                <div className="auth-header">
                    <div className="logo-circ">
                        <LogIn size={24} className="text-primary" />
                    </div>
                    <h1>Welcome Back</h1>
                    <p>Access the caregiver dashboard to monitor your team.</p>
                </div>

                <form onSubmit={handleLogin} className="auth-form">
                    {error && (
                        <div className="auth-error">
                            <ShieldAlert size={16} />
                            <span>{error}</span>
                        </div>
                    )}

                    <div className="form-group">
                        <label>Email Address</label>
                        <input
                            type="email"
                            placeholder="doc@caretrack.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label>Password</label>
                        <input
                            type="password"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    <button type="submit" className="auth-button" disabled={loading}>
                        {loading ? 'Entering Sanctuary...' : 'Login to Dashboard'}
                    </button>
                </form>

                <div className="auth-footer">
                    <p>New to the care team? <Link to="/signup">Register as Caregiver</Link></p>
                </div>
            </div>
        </div>
    );
}
