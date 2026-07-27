import { useEffect, useState } from 'react';
import { useOutletContext } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { MessageSquare, MoreVertical, ExternalLink, X, Plus } from 'lucide-react';

interface Patient {
    id: string;
    full_name: string;
    conditions: string[];
    role: string;
}

export default function Patients() {
    const [patients, setPatients] = useState<Patient[]>([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [inviteCode, setInviteCode] = useState('');
    const [modalError, setModalError] = useState('');
    const [submitting, setSubmitting] = useState(false);
    const { openChat } = useOutletContext<{ openChat: (id: string, name: string) => void }>();

    const fetchPatients = async () => {
        setLoading(true);
        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) return;

            // Fetch patient IDs linked to this caregiver
            const { data: links, error: linksError } = await supabase
                .from('care_links')
                .select('patient_id')
                .eq('caregiver_id', user.id);

            if (linksError) throw linksError;

            const patientIds = links ? links.map(l => l.patient_id) : [];

            if (patientIds.length === 0) {
                setPatients([]);
                return;
            }

            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('role', 'patient')
                .in('id', patientIds);
            
            if (error) throw error;
            if (data) setPatients(data);
        } catch (e) {
            console.error('Error fetching patients:', e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchPatients();
    }, []);

    const handleAddPatientSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setModalError('');
        setSubmitting(true);

        const cleanCode = inviteCode.trim();
        if (cleanCode.length !== 6) {
            setModalError('Please enter a valid 6-digit invitation code.');
            setSubmitting(false);
            return;
        }

        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) throw new Error('Caregiver session not found. Please log in.');

            // 1. Fetch invitation code details
            const { data: codeData, error: fetchError } = await supabase
                .from('invitation_codes')
                .select('*')
                .eq('code', cleanCode)
                .single();

            if (fetchError || !codeData) {
                setModalError('Invalid or expired invitation code. Please verify the code.');
                setSubmitting(false);
                return;
            }

            // Check expiration
            if (new Date(codeData.expires_at) < new Date()) {
                setModalError('This invitation code has expired.');
                setSubmitting(false);
                return;
            }

            // 2. Check if already linked
            const { data: existingLink } = await supabase
                .from('care_links')
                .select('*')
                .eq('patient_id', codeData.patient_id)
                .eq('caregiver_id', user.id)
                .maybeSingle();

            if (existingLink) {
                setModalError('This patient is already linked to your profile.');
                setSubmitting(false);
                return;
            }

            // 3. Create care link
            const { error: linkError } = await supabase
                .from('care_links')
                .insert({
                    patient_id: codeData.patient_id,
                    caregiver_id: user.id,
                    role: 'caregiver',
                    status: 'active'
                });

            if (linkError) throw linkError;

            // 4. Delete used invitation code
            await supabase
                .from('invitation_codes')
                .delete()
                .eq('code', cleanCode);

            // Close and reset
            setShowModal(false);
            setInviteCode('');
            // Reload list
            await fetchPatients();
        } catch (err: any) {
            console.error('Error adding patient:', err);
            setModalError(err.message || 'An unexpected error occurred.');
        } finally {
            setSubmitting(false);
        }
    };

    if (loading) return <div className="p-8">Consulting patient records...</div>;

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1>Patient Directory</h1>
                <button 
                    onClick={() => setShowModal(true)}
                    className="auth-button flex items-center gap-2" 
                    style={{ padding: '10px 24px', fontSize: '14px', cursor: 'pointer', display: 'flex', alignItems: 'center' }}
                >
                    <Plus size={16} />
                    Add New Patient
                </button>
            </div>

            <div className="card">
                <table className="data-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Conditions</th>
                            <th>Status/Alerts</th>
                            <th>Last Active</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {patients.length === 0 ? (
                            <tr>
                                <td colSpan={5} style={{ textAlign: 'center', padding: '48px', color: 'var(--text-secondary)' }}>
                                    No patients found. Share your invitation code from the mobile app to link a patient.
                                </td>
                            </tr>
                        ) : (
                            patients.map((patient) => (
                                <tr key={patient.id}>
                                    <td>
                                        <div className="flex items-center gap-3">
                                            <div className="avatar-sm" style={{ background: 'var(--primary-light)', color: 'var(--primary)', fontWeight: 600 }}>{patient.full_name ? patient.full_name[0].toUpperCase() : 'P'}</div>
                                            <strong>{patient.full_name || 'Anonymous Patient'}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div className="flex gap-2">
                                            {patient.conditions?.map(c => (
                                                <span key={c} className="badge" style={{ background: '#e0e7ff', color: '#4338ca' }}>{c}</span>
                                            )) || <span style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>None</span>}
                                        </div>
                                    </td>
                                    <td>
                                        <span className="badge badge-success">Stable</span>
                                    </td>
                                    <td>Today, 10:45 AM</td>
                                    <td>
                                        <div className="flex gap-2">
                                            <button 
                                                onClick={() => openChat(patient.id, patient.full_name)}
                                                className="p-2 hover:bg-gray-100 rounded-lg text-primary"
                                                style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}
                                                title="Open Care Chat"
                                            >
                                                <MessageSquare size={20} />
                                            </button>
                                            <button className="p-2 hover:bg-gray-100 rounded-lg text-secondary" style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                                                <ExternalLink size={20} />
                                            </button>
                                            <button className="p-2 hover:bg-gray-100 rounded-lg" style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                                                <MoreVertical size={20} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {showModal && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    backgroundColor: 'rgba(15, 23, 42, 0.5)',
                    backdropFilter: 'blur(4px)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 1000
                }}>
                    <div className="card" style={{
                        width: '100%',
                        maxWidth: '460px',
                        padding: '32px',
                        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
                        position: 'relative',
                        borderRadius: '16px',
                        border: '1px solid var(--border)'
                    }}>
                        <button 
                            onClick={() => { setShowModal(false); setModalError(''); setInviteCode(''); }}
                            style={{
                                position: 'absolute',
                                top: '20px',
                                right: '20px',
                                background: 'transparent',
                                border: 'none',
                                cursor: 'pointer',
                                color: 'var(--text-secondary)'
                            }}
                        >
                            <X size={20} />
                        </button>

                        <h2 style={{ marginBottom: '8px', fontSize: '20px', fontWeight: 700 }}>Add New Patient</h2>
                        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '24px' }}>
                            Enter the 6-digit invitation code generated by the patient on their CareTrackAI mobile app.
                        </p>

                        <form onSubmit={handleAddPatientSubmit}>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)', marginBottom: '8px' }}>
                                    6-Digit Invitation Code
                                </label>
                                <input 
                                    type="text"
                                    maxLength={6}
                                    placeholder="e.g. 123456"
                                    value={inviteCode}
                                    onChange={(e) => setInviteCode(e.target.value.replace(/[^0-9]/g, ''))}
                                    style={{
                                        width: '100%',
                                        padding: '12px 16px',
                                        fontSize: '18px',
                                        letterSpacing: '4px',
                                        textAlign: 'center',
                                        fontWeight: '700',
                                        borderRadius: '8px',
                                        border: '1px solid var(--border)',
                                        outline: 'none',
                                        transition: 'border-color 0.2s',
                                    }}
                                    required
                                />
                            </div>

                            {modalError && (
                                <div style={{ 
                                    padding: '12px 16px', 
                                    borderRadius: '8px', 
                                    backgroundColor: '#fef2f2', 
                                    color: 'var(--danger)', 
                                    fontSize: '13px', 
                                    marginBottom: '20px',
                                    border: '1px solid #fee2e2'
                                }}>
                                    {modalError}
                                </div>
                            )}

                            <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                                <button 
                                    type="button"
                                    onClick={() => { setShowModal(false); setModalError(''); setInviteCode(''); }}
                                    style={{
                                        padding: '10px 20px',
                                        borderRadius: '8px',
                                        border: '1px solid var(--border)',
                                        backgroundColor: 'transparent',
                                        color: 'var(--text-secondary)',
                                        fontSize: '14px',
                                        fontWeight: 600,
                                        cursor: 'pointer'
                                    }}
                                >
                                    Cancel
                                </button>
                                <button 
                                    type="submit"
                                    disabled={submitting}
                                    style={{
                                        padding: '10px 20px',
                                        borderRadius: '8px',
                                        border: 'none',
                                        backgroundColor: 'var(--primary)',
                                        color: '#ffffff',
                                        fontSize: '14px',
                                        fontWeight: 600,
                                        cursor: 'pointer',
                                        opacity: submitting ? 0.7 : 1
                                    }}
                                >
                                    {submitting ? 'Linking...' : 'Link Patient'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
