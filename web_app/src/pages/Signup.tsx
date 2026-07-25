import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { UserPlus, ShieldPlus } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import DOMPurify from 'dompurify';

const signupSchema = z.object({
    fullName: z.string().min(2, 'Name must be at least 2 characters'),
    role: z.enum(['caregiver', 'doctor']),
    email: z.string().email('Invalid email address'),
    password: z.string()
        .min(8, 'Password must be at least 8 characters')
        .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
        .regex(/[0-9]/, 'Password must contain at least one number')
        .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),
    consent: z.literal(true, {
        errorMap: () => ({ message: 'You must agree to the Privacy Policy and data processing terms.' })
    })
});

type SignupFormValues = z.infer<typeof signupSchema>;

export default function Signup() {
    const { register, handleSubmit, formState: { errors } } = useForm<SignupFormValues>({
        resolver: zodResolver(signupSchema),
        defaultValues: {
            role: 'caregiver',
        }
    });
    
    const [loading, setLoading] = useState(false);
    const [authError, setAuthError] = useState<string | null>(null);
    const navigate = useNavigate();

    const onSubmit = async (data: SignupFormValues) => {
        setLoading(true);
        setAuthError(null);

        try {
            // Sanitize inputs before hitting API (Defense in depth against XSS)
            const cleanFullName = DOMPurify.sanitize(data.fullName);
            const cleanEmail = DOMPurify.sanitize(data.email);

            // 1. Sign up user
            const { data: authData, error: signupError } = await supabase.auth.signUp({
                email: cleanEmail,
                password: data.password,
            });

            if (signupError) throw signupError;

            if (authData.user) {
                // 2. Create profile entry
                const { error: profileError } = await supabase
                    .from('profiles')
                    .insert({
                        id: authData.user.id,
                        full_name: cleanFullName,
                        role: data.role,
                        consent_given: data.consent,
                        consent_date: new Date().toISOString()
                    });

                if (profileError) throw profileError;
            }

            navigate('/dashboard');
        } catch (err: any) {
            setAuthError(err.message || 'Failed to sign up');
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

                <form onSubmit={handleSubmit(onSubmit)} className="auth-form">
                    {authError && (
                        <div className="auth-error">
                            <ShieldPlus size={16} />
                            <span>{authError}</span>
                        </div>
                    )}

                    <div className="form-group">
                        <label>Display Name</label>
                        <input
                            type="text"
                            placeholder="Dr. Julia Sterling"
                            {...register('fullName')}
                            className={errors.fullName ? 'input-error' : ''}
                        />
                        {errors.fullName && <span className="error-text">{errors.fullName.message}</span>}
                    </div>

                    <div className="form-group">
                        <label>Professional Role</label>
                        <select 
                            {...register('role')}
                            className="form-select"
                        >
                            <option value="caregiver">Caregiver / Family Member</option>
                            <option value="doctor">Medical Professional (Doctor)</option>
                        </select>
                        {errors.role && <span className="error-text">{errors.role.message}</span>}
                    </div>

                    <div className="form-group">
                        <label>Professional Email</label>
                        <input
                            type="email"
                            placeholder="julia@hospital.com"
                            {...register('email')}
                            className={errors.email ? 'input-error' : ''}
                        />
                        {errors.email && <span className="error-text">{errors.email.message}</span>}
                    </div>

                    <div className="form-group">
                        <label>Secure Password</label>
                        <input
                            type="password"
                            placeholder="••••••••"
                            {...register('password')}
                            className={errors.password ? 'input-error' : ''}
                        />
                        {errors.password && <span className="error-text">{errors.password.message}</span>}
                    </div>

                    <div className="form-group checkbox-group" style={{ display: 'flex', alignItems: 'flex-start', gap: '8px', marginTop: '16px' }}>
                        <input 
                            type="checkbox" 
                            id="consent" 
                            {...register('consent')}
                            style={{ marginTop: '4px' }}
                        />
                        <label htmlFor="consent" style={{ fontSize: '12px', lineHeight: '1.4', color: '#666' }}>
                            I explicitly consent to the processing of my personal and health data in accordance with the 
                            <a href="https://app.caretrackai.app/privacy" target="_blank" rel="noopener noreferrer"> Privacy Policy</a> 
                            (required for GDPR/PDPL compliance).
                        </label>
                    </div>
                    {errors.consent && <span className="error-text" style={{ marginTop: '-8px', display: 'block' }}>{errors.consent.message}</span>}

                    <button type="submit" className="auth-button" disabled={loading} style={{ marginTop: '16px' }}>
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
