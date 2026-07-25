import { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { Activity, Users, Bell, LayoutDashboard, LogOut, CreditCard } from 'lucide-react';
import { supabase } from '../lib/supabase';
import ChatOverlay from './ChatOverlay';

export default function Layout() {
    const [activeChat, setActiveChat] = useState<{ id: string, name: string } | null>(null);
    const navigate = useNavigate();

    const handleLogout = async () => {
        await supabase.auth.signOut();
        navigate('/login');
    };

    // Global listener for opening chat (triggered by child components)
    // In a real app, use a Context Provider. Here we'll pass via Outlet context.
    
    return (
        <div className="app-container">
            <aside className="sidebar">
                <div className="sidebar-logo">
                    <Activity size={32} />
                    CareTrack
                </div>

                <nav style={{ flex: 1 }}>
                    <NavLink
                        to="/dashboard"
                        className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
                    >
                        <LayoutDashboard size={20} />
                        Overview
                    </NavLink>
                    <NavLink
                        to="/patients"
                        className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
                    >
                        <Users size={20} />
                        Patients
                    </NavLink>
                    <NavLink
                        to="/alerts"
                        className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
                    >
                        <Bell size={20} />
                        AI Alerts
                    </NavLink>
                    <NavLink
                        to="/billing"
                        className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
                    >
                        <CreditCard size={20} />
                        Billing
                    </NavLink>
                </nav>

                <button onClick={handleLogout} className="nav-link" style={{ border: 'none', background: 'none', width: '100%', cursor: 'pointer', marginTop: 'auto' }}>
                    <LogOut size={20} />
                    Logout
                </button>
            </aside>

            <main className="main-content">
                <Outlet context={{ openChat: (id: string, name: string) => setActiveChat({ id, name }) }} />
            </main>

            {activeChat && (
                <ChatOverlay 
                    patientId={activeChat.id} 
                    patientName={activeChat.name} 
                    onClose={() => setActiveChat(null)} 
                />
            )}
        </div>
    );
}
