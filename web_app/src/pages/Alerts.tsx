import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { AlertCircle, Clock, CheckCircle, User } from 'lucide-react';

interface Notification {
    id: string;
    patient_id: string;
    type: string;
    message: string;
    created_at: string;
    is_read: boolean;
    profiles?: { full_name: string };
}

export default function Alerts() {
    const [alerts, setAlerts] = useState<Notification[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchAlerts = async () => {
            const { data } = await supabase
                .from('notifications')
                .select('*, profiles:patient_id(full_name)')
                .order('created_at', { ascending: false });

            if (data) setAlerts(data);
            setLoading(false);
        };

        fetchAlerts();

        const channel = supabase
            .channel('notifications_page')
            .on('postgres_changes', { 
                event: 'INSERT', 
                schema: 'public', 
                table: 'notifications' 
            }, async (payload) => {
                const { data: profile } = await supabase
                    .from('profiles')
                    .select('full_name')
                    .eq('id', payload.new.patient_id)
                    .single();

                const newAlert = { ...payload.new, profiles: profile } as Notification;
                setAlerts(prev => [newAlert, ...prev]);
            })
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, []);

    const markAsRead = async (id: string) => {
        const { error } = await supabase
            .from('notifications')
            .update({ is_read: true })
            .eq('id', id);

        if (!error) {
            setAlerts(prev => prev.map(a => a.id === id ? { ...a, is_read: true } : a));
        }
    };

    if (loading) return <div className="p-8">Synchronizing with care logs...</div>;

    return (
        <div>
            <h1 style={{ marginBottom: '8px' }}>Active AI Alerts</h1>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '32px' }}>
                Real-time interventions escalated by the CareTrack AI system.
            </p>

            <div className="alerts-list" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {alerts.length === 0 ? (
                    <div className="card" style={{ textAlign: 'center', padding: '64px' }}>
                        <CheckCircle size={48} style={{ color: 'var(--success)', marginBottom: '16px', opacity: 0.5 }} />
                        <p style={{ color: 'var(--text-secondary)' }}>All systems normal. No pending alerts.</p>
                    </div>
                ) : (
                    alerts.map(alert => (
                        <div 
                            key={alert.id} 
                            className="card" 
                            style={{ 
                                display: 'flex', 
                                gap: '20px',
                                borderLeft: `6px solid ${alert.is_read ? 'var(--border)' : (alert.type.includes('critical') ? 'var(--danger)' : 'var(--warning)')}`,
                                opacity: alert.is_read ? 0.7 : 1
                            }}
                        >
                            <div style={{ 
                                width: '48px', 
                                height: '48px', 
                                borderRadius: '12px', 
                                backgroundColor: alert.type.includes('critical') ? '#fee2e2' : '#fef3c7',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                color: alert.type.includes('critical') ? 'var(--danger)' : 'var(--warning)'
                            }}>
                                <AlertCircle size={24} />
                            </div>

                            <div style={{ flex: 1 }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <User size={16} className="text-secondary" />
                                        <strong style={{ fontSize: '16px' }}>{alert.profiles?.full_name || 'System Alert'}</strong>
                                    </div>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', color: 'var(--text-secondary)' }}>
                                        <Clock size={14} />
                                        {new Date(alert.created_at).toLocaleString()}
                                    </div>
                                </div>
                                
                                <p style={{ fontSize: '15px', color: 'var(--text-primary)', lineHeight: 1.5 }}>{alert.message}</p>
                                
                                <div style={{ marginTop: '16px', display: 'flex', gap: '12px' }}>
                                    {!alert.is_read && (
                                        <button 
                                            onClick={() => markAsRead(alert.id)}
                                            style={{ 
                                                padding: '8px 16px', 
                                                borderRadius: '8px', 
                                                border: 'none', 
                                                backgroundColor: 'var(--primary-light)', 
                                                color: 'var(--primary)',
                                                fontSize: '13px',
                                                fontWeight: 600,
                                                cursor: 'pointer'
                                            }}
                                        >
                                            Acknowledge
                                        </button>
                                    )}
                                    <button 
                                        style={{ 
                                            padding: '8px 16px', 
                                            borderRadius: '8px', 
                                            border: '1px solid var(--border)', 
                                            backgroundColor: 'transparent', 
                                            color: 'var(--text-secondary)',
                                            fontSize: '13px',
                                            fontWeight: 600,
                                            cursor: 'pointer'
                                        }}
                                    >
                                        View Patient History
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
