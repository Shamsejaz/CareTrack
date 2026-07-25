import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { LogIn, ShieldAlert } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import DOMPurify from 'dompurify';

const loginSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function Login() {
    const { register, handleSubmit, formState: { errors } } = useForm<LoginFormValues>({
        resolver: zodResolver(loginSchema),
    });

    const [loading, setLoading] = useState(false);
    const [authError, setAuthError] = useState<string | null>(null);
    const navigate = useNavigate();

    const handleGoogleLogin = async () => {
        setAuthError(null);
        try {
            const { error } = await supabase.auth.signInWithOAuth({
                provider: 'google',
                options: {
                    redirectTo: `${window.location.origin}/dashboard`,
                },
            });
            if (error) throw error;
        } catch (err: any) {
            setAuthError(err.message || 'Failed to initialize Google login');
        }
    };

    const onSubmit = async (data: LoginFormValues) => {
        setLoading(true);
        setAuthError(null);

        try {
            // Sanitize input (defense in depth)
            const cleanEmail = DOMPurify.sanitize(data.email);

            const { error } = await supabase.auth.signInWithPassword({
                email: cleanEmail,
                password: data.password,
            });

            if (error) throw error;
            navigate('/dashboard');
        } catch (err: any) {
            let message = err.message || 'Failed to login';
            if (message.toLowerCase().includes('invalid login credentials') || message.toLowerCase().includes('invalid_credentials')) {
                message = 'Incorrect email or password. Please verify and try again.';
            } else if (message.toLowerCase().includes('email not confirmed')) {
                message = 'Your email address is not verified yet. Please check your inbox.';
            } else if (message.toLowerCase().includes('rate limit')) {
                message = 'Too many login attempts. Please try again in a few minutes.';
            }
            setAuthError(message);
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

                <div className="oauth-section" style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
                    <button 
                        type="button" 
                        onClick={handleGoogleLogin}
                        style={{ 
                            display: 'flex', 
                            alignItems: 'center', 
                            justifyContent: 'center', 
                            gap: '10px', 
                            width: '100%', 
                            padding: '10px', 
                            backgroundColor: '#fff', 
                            border: '1px solid #d1d5db', 
                            borderRadius: '8px', 
                            color: '#374151', 
                            fontWeight: '500', 
                            cursor: 'pointer',
                            transition: 'background-color 0.2s'
                        }}
                    >
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                        </svg>
                        Continue with Google
                    </button>
                    <div style={{ display: 'flex', alignItems: 'center', margin: '8px 0' }}>
                        <div style={{ flex: 1, height: '1px', backgroundColor: '#e5e7eb' }}></div>
                        <span style={{ padding: '0 10px', fontSize: '14px', color: '#6b7280' }}>or</span>
                        <div style={{ flex: 1, height: '1px', backgroundColor: '#e5e7eb' }}></div>
                    </div>
                </div>

                <form onSubmit={handleSubmit(onSubmit)} className="auth-form">
                    {authError && (
                        <div className="auth-error">
                            <ShieldAlert size={16} />
                            <span>{authError}</span>
                        </div>
                    )}

                    <div className="form-group">
                        <label>Email Address</label>
                        <input
                            type="email"
                            placeholder="doc@caretrackai.com"
                            {...register('email')}
                            className={errors.email ? 'input-error' : ''}
                        />
                        {errors.email && <span className="error-text">{errors.email.message}</span>}
                    </div>

                    <div className="form-group">
                        <label>Password</label>
                        <input
                            type="password"
                            placeholder="••••••••"
                            {...register('password')}
                            className={errors.password ? 'input-error' : ''}
                        />
                        {errors.password && <span className="error-text">{errors.password.message}</span>}
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
