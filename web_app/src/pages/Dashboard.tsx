import { useEffect, useState } from 'react';
import { Activity, Users, AlertTriangle, ShieldCheck } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Notification {
    id: string;
    patient_id: string;
    type: string;
    message: string;
    created_at: string;
    is_read: boolean;
    profiles?: { full_name: string };
}

export default function Dashboard() {
    const [stats, setStats] = useState({ patients: 0, alerts: 0, compliance: '84%' });
    const [alerts, setAlerts] = useState<Notification[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            // 1. Fetch Stats
            const { count: patientCount } = await supabase
                .from('profiles')
                .select('*', { count: 'exact', head: true })
                .eq('role', 'patient');

            const { count: alertCount } = await supabase
                .from('notifications')
                .select('*', { count: 'exact', head: true })
                .eq('is_read', false);

            setStats(prev => ({ ...prev, patients: patientCount || 0, alerts: alertCount || 0 }));

            // 2. Fetch Recent Alerts
            const { data: alertData } = await supabase
                .from('notifications')
                .select('*, profiles:patient_id(full_name)')
                .order('created_at', { ascending: false })
                .limit(5);

            if (alertData) setAlerts(alertData);
            setLoading(false);
        };

        fetchData();

        // 3. Realtime Alerts
        const channel = supabase
            .channel('notifications_dashboard')
            .on('postgres_changes', { 
                event: 'INSERT', 
                schema: 'public', 
                table: 'notifications' 
            }, async (payload) => {
                // Get patient name for the new alert
                const { data: profile } = await supabase
                    .from('profiles')
                    .select('full_name')
                    .eq('id', payload.new.patient_id)
                    .single();

                const newAlert = { ...payload.new, profiles: profile } as Notification;
                setAlerts(prev => [newAlert, ...prev.slice(0, 4)]);
                setStats(prev => ({ ...prev, alerts: prev.alerts + 1 }));
            })
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, []);

    if (loading) return <div className="p-8">Syncing clinical data...</div>;

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1>Clinical Overview</h1>
                <div className="flex gap-4">
                    <span className="flex items-center gap-2 text-sm text-secondary">
                        <ShieldCheck size={16} className="text-success" />
                        System Status: Operational
                    </span>
                </div>
            </div>

            <div className="metric-grid">
                <div className="card metric-card">
                    <div className="metric-header">
                        Total Patients
                        <Users size={20} className="text-secondary" />
                    </div>
                    <div className="metric-value">{stats.patients}</div>
                    <div className="metric-trend trend-neutral">Active Monitored</div>
                </div>

                <div className="card metric-card" style={{ borderLeft: stats.alerts > 0 ? '4px solid #D32F2F' : '' }}>
                    <div className="metric-header">
                        Pending Alerts
                        <AlertTriangle size={20} className="text-danger" />
                    </div>
                    <div className="metric-value">{stats.alerts}</div>
                    <div className="metric-trend trend-up">{stats.alerts > 0 ? 'Action Required' : 'All Clear'}</div>
                </div>

                <div className="card metric-card">
                    <div className="metric-header">
                        Care Compliance
                        <Activity size={20} className="text-secondary" />
                    </div>
                    <div className="metric-value">{stats.compliance}</div>
                    <div className="metric-trend trend-down">Last 7 Days</div>
                </div>
            </div>

            <div className="card">
                <h2 style={{ marginBottom: '24px', fontSize: '18px' }}>Recent AI Notifications</h2>
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>Patient</th>
                            <th>Alert Type</th>
                            <th>Critical Insight</th>
                            <th>Timestamp</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        {alerts.length === 0 ? (
                            <tr>
                                <td colSpan={5} style={{ textAlign: 'center', padding: '48px', color: '#64748B' }}>
                                    No recent alerts detected. System is quiet.
                                </td>
                            </tr>
                        ) : (
                            alerts.map((alert) => (
                                <tr key={alert.id} className={alert.is_read ? '' : 'bg-red-50'}>
                                    <td>
                                        <strong>{alert.profiles?.full_name || 'Unknown Patient'}</strong>
                                    </td>
                                    <td>
                                        <span className="badge" style={{ background: '#ffdad6', color: '#93000a' }}>
                                            {alert.type.replace('_', ' ').toUpperCase()}
                                        </span>
                                    </td>
                                    <td>{alert.message}</td>
                                    <td>{new Date(alert.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</td>
                                    <td>
                                        {alert.is_read ? (
                                            <span className="badge badge-success">Resolved</span>
                                        ) : (
                                            <button className="badge badge-danger" style={{ border: 'none', cursor: 'pointer' }}>
                                                Acknowledge
                                            </button>
                                        )}
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
