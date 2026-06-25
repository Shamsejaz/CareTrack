import { useEffect, useState } from 'react';
import { useOutletContext } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { MessageSquare, MoreVertical, ExternalLink } from 'lucide-react';

interface Patient {
    id: string;
    full_name: string;
    conditions: string[];
    role: string;
}

export default function Patients() {
    const [patients, setPatients] = useState<Patient[]>([]);
    const [loading, setLoading] = useState(true);
    const { openChat } = useOutletContext<{ openChat: (id: string, name: string) => void }>();

    useEffect(() => {
        const fetchPatients = async () => {
            // For this phase, we fetch all patients. 
            // In a real app, we join with care_links.
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('role', 'patient');
            
            if (data) setPatients(data);
            setLoading(false);
        };

        fetchPatients();
    }, []);

    if (loading) return <div className="p-8">Consulting patient records...</div>;

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1>Patient Directory</h1>
                <button className="auth-button" style={{ padding: '10px 24px', fontSize: '14px' }}>
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
                                <td colSpan={5} style={{ textAlign: 'center', padding: '48px' }}>
                                    No patients found. Share your invitation code from the mobile app to link a patient.
                                </td>
                            </tr>
                        ) : (
                            patients.map((patient) => (
                                <tr key={patient.id}>
                                    <td>
                                        <div className="flex items-center gap-3">
                                            <div className="avatar-sm" style={{ background: '#f1f5f9' }}>{patient.full_name[0]}</div>
                                            <strong>{patient.full_name}</strong>
                                        </div>
                                    </td>
                                    <td>
                                        <div className="flex gap-2">
                                            {patient.conditions?.map(c => (
                                                <span key={c} className="badge" style={{ background: '#e0e7ff', color: '#4338ca' }}>{c}</span>
                                            )) || 'N/A'}
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
                                                title="Open Care Chat"
                                            >
                                                <MessageSquare size={20} />
                                            </button>
                                            <button className="p-2 hover:bg-gray-100 rounded-lg text-secondary">
                                                <ExternalLink size={20} />
                                            </button>
                                            <button className="p-2 hover:bg-gray-100 rounded-lg">
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
        </div>
    );
}
