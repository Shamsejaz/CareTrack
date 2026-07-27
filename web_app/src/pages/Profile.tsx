import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { User, Save, ShieldAlert, CheckCircle2 } from 'lucide-react';
import DOMPurify from 'dompurify';

export default function Profile() {
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);
    const [email, setEmail] = useState('');
    
    const [formData, setFormData] = useState({
        fullName: '',
        role: ''
    });

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const { data: { user } } = await supabase.auth.getUser();
            
            if (user) {
                setEmail(user.email || '');
                
                const { data, error } = await supabase
                    .from('profiles')
                    .select('full_name, role')
                    .eq('id', user.id)
                    .single();

                if (error) throw error;
                
                if (data) {
                    setFormData({
                        fullName: data.full_name || '',
                        role: data.role || ''
                    });
                }
            }
        } catch (error) {
            console.error('Error loading profile:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        setSaving(true);
        setMessage(null);

        try {
            const cleanFullName = DOMPurify.sanitize(formData.fullName);
            const { data: { user } } = await supabase.auth.getUser();

            if (!user) throw new Error('No active user session');

            const { error } = await supabase
                .from('profiles')
                .update({
                    full_name: cleanFullName,
                    role: formData.role,
                })
                .eq('id', user.id);

            if (error) throw error;

            setMessage({ text: 'Profile updated successfully!', type: 'success' });
        } catch (error: any) {
            setMessage({ text: error.message || 'Failed to update profile', type: 'error' });
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%', color: 'var(--text-secondary)' }}>
                Loading profile...
            </div>
        );
    }

    return (
        <div>
            <div className="page-header">
                <h1>Profile Settings</h1>
                <p>Manage your account details and professional role.</p>
            </div>

            <div className="card" style={{ maxWidth: '600px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '32px' }}>
                    <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: 'var(--primary-light)', color: 'var(--primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <User size={32} />
                    </div>
                    <div>
                        <h2 style={{ fontSize: '20px', color: 'var(--primary)' }}>{formData.fullName || 'User'}</h2>
                        <span className="badge badge-success" style={{ marginTop: '4px' }}>{formData.role || 'Member'}</span>
                    </div>
                </div>

                {message && (
                    <div style={{ 
                        padding: '12px 16px', 
                        borderRadius: '8px', 
                        marginBottom: '24px', 
                        display: 'flex', 
                        alignItems: 'center', 
                        gap: '8px',
                        background: message.type === 'error' ? 'var(--danger-light)' : 'var(--success-light)',
                        color: message.type === 'error' ? 'var(--danger)' : 'var(--success)'
                    }}>
                        {message.type === 'error' ? <ShieldAlert size={18} /> : <CheckCircle2 size={18} />}
                        <span style={{ fontWeight: '600', fontSize: '14px' }}>{message.text}</span>
                    </div>
                )}

                <form onSubmit={handleSave} className="auth-form" style={{ gap: '24px' }}>
                    <div className="form-group">
                        <label>Email Address</label>
                        <input 
                            type="email" 
                            value={email} 
                            disabled 
                            style={{ opacity: 0.7, cursor: 'not-allowed' }}
                            title="Email cannot be changed"
                        />
                    </div>

                    <div className="form-group">
                        <label>Display Name</label>
                        <input 
                            type="text" 
                            value={formData.fullName}
                            onChange={(e) => setFormData({...formData, fullName: e.target.value})}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label>Professional Role</label>
                        <select 
                            className="form-select"
                            value={formData.role}
                            onChange={(e) => setFormData({...formData, role: e.target.value})}
                            required
                        >
                            <option value="">Select a role...</option>
                            <option value="Caregiver / Family Member">Caregiver / Family Member</option>
                            <option value="Nurse / Medical Staff">Nurse / Medical Staff</option>
                            <option value="Doctor / Physician">Doctor / Physician</option>
                            <option value="Administrator">Administrator</option>
                        </select>
                    </div>

                    <button 
                        type="submit" 
                        className="btn-primary" 
                        disabled={saving}
                        style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginTop: '12px' }}
                    >
                        <Save size={18} />
                        {saving ? 'Saving Changes...' : 'Save Profile'}
                    </button>
                </form>
            </div>
        </div>
    );
}
