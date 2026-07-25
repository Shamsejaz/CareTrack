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
