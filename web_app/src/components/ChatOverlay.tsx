import { useState, useEffect, useRef } from 'react';
import { supabase } from '../lib/supabase';
import { Send, X } from 'lucide-react';

interface ChatOverlayProps {
    patientId: string;
    patientName: string;
    onClose: () => void;
}

export default function ChatOverlay({ patientId, patientName, onClose }: ChatOverlayProps) {
    const [messages, setMessages] = useState<any[]>([]);
    const [input, setInput] = useState('');
    const [currentUserId, setCurrentUserId] = useState<string | null>(null);
    const scrollRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        // 1. Get current user
        supabase.auth.getUser().then(({ data }) => {
            setCurrentUserId(data.user?.id || null);
        });

        // 2. Initial fetch
        const fetchMessages = async () => {
            const { data } = await supabase
                .from('chat_messages')
                .select('*')
                .or(`sender_id.eq.${patientId},receiver_id.eq.${patientId}`)
                .order('created_at', { ascending: true });
            
            if (data) setMessages(data);
        };
        fetchMessages();

        // 3. Realtime subscription
        const channel = supabase
            .channel('chat_messages')
            .on('postgres_changes', { 
                event: 'INSERT', 
                schema: 'public', 
                table: 'chat_messages' 
            }, (payload) => {
                if (
                    (payload.new.sender_id === patientId || payload.new.receiver_id === patientId)
                ) {
                    setMessages((prev) => [...prev, payload.new]);
                }
            })
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [patientId]);

    useEffect(() => {
        scrollRef.current?.scrollTo(0, scrollRef.current.scrollHeight);
    }, [messages]);

    const sendMessage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!input.trim() || !currentUserId) return;

        const { error } = await supabase.from('chat_messages').insert({
            sender_id: currentUserId,
            receiver_id: patientId,
            content: input.trim()
        });

        if (!error) setInput('');
    };

    return (
        <div className="chat-overlay">
            <div className="chat-header">
                <div className="flex items-center gap-3">
                    <div className="avatar-sm">{patientName[0]}</div>
                    <div>
                        <div className="font-bold">{patientName}</div>
                        <div className="text-xs text-secondary">Patient - Professional Channel</div>
                    </div>
                </div>
                <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full">
                    <X size={20} />
                </button>
            </div>

            <div className="chat-body" ref={scrollRef}>
                {messages.map((msg) => {
                    const isMe = msg.sender_id === currentUserId;
                    return (
                        <div key={msg.id} className={`chat-bubble-container ${isMe ? 'chat-me' : 'chat-them'}`}>
                            <div className="chat-bubble">
                                {msg.content}
                            </div>
                        </div>
                    );
                })}
            </div>

            <form onSubmit={sendMessage} className="chat-footer">
                <input 
                    type="text" 
                    placeholder="Provide guidance..."
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                />
                <button type="submit" className="send-btn">
                    <Send size={18} />
                </button>
            </form>
        </div>
    );
}
