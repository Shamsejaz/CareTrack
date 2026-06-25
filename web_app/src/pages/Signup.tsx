import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { UserPlus, ShieldPlus } from 'lucide-react';

export default function Signup() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [fullName, setFullName] = useState('');
    const [role, setRole] = useState<'caregiver' | 'doctor'>('caregiver');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const navigate = useNavigate();

    const handleSignup = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            // 1. Sign up user
            const { data, error: signupError } = await supabase.auth.signUp({
                email,
                password,
            });

            if (signupError) throw signupError;

            if (data.user) {
                // 2. Create profile entry
                const { error: profileError } = await supabase
                    .from('profiles')
                    .insert({
                        id: data.user.id,
                        full_name: fullName,
                        role: role,
                    });

                if (profileError) throw profileError;
            }

            navigate('/dashboard');
        } catch (err: any) {
            setError(err.message || 'Failed to sign up');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="auth-container">
            <div className="auth-card">
                <div className="auth-header">
                    <div className="logo-circ">
                        <UserPlus size={24} className="text-primary" />
                    </div>
                    <h1>Create Team Account</h1>
                    <p>Register to monitor patients and collaborate with the care team.</p>
                </div>

                <form onSubmit={handleSignup} className="auth-form">
                    {error && (
                        <div className="auth-error">
                            <ShieldPlus size={16} />
                            <span>{error}</span>
                        </div>
                    )}

                    <div className="form-group">
                        <label>Display Name</label>
                        <input
                            type="text"
                            placeholder="Dr. Julia Sterling"
                            value={fullName}
                            onChange={(e) => setFullName(e.target.value)}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label>Professional Role</label>
                        <select 
                            value={role} 
                            onChange={(e) => setRole(e.target.value as any)}
                            className="form-select"
                        >
                            <option value="caregiver">Caregiver / Family Member</option>
                            <option value="doctor">Medical Professional (Doctor)</option>
                        </select>
                    </div>

                    <div className="form-group">
                        <label>Professional Email</label>
                        <input
                            type="email"
                            placeholder="julia@hospital.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label>Secure Password</label>
                        <input
                            type="password"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    <button type="submit" className="auth-button" disabled={loading}>
                        {loading ? 'Consulting Servers...' : 'Complete Registration'}
                    </button>
                </form>

                <div className="auth-footer">
                    <p>Already have an account? <Link to="/login">Sign in here</Link></p>
                </div>
            </div>
        </div>
    );
}
