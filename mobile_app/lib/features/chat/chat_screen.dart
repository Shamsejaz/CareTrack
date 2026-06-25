import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/auth_provider.dart';

final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, receiverId) {
  final supabase = ref.watch(supabaseProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) return Stream.value([]);

  // Note: Realtime filters are limited. In production, consider a conversation_id.
  // For now, we listen to all messages for this user and filter locally.
  return supabase
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((data) => data.map((e) => Map<String, dynamic>.from(e)).where((m) => 
          (m['sender_id'] == currentUser.id && m['receiver_id'] == receiverId) ||
          (m['sender_id'] == receiverId && m['receiver_id'] == currentUser.id)
      ).toList());
});

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverId;
  const ChatScreen({super.key, required this.receiverId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    _messageController.clear();

    try {
      await ref.read(supabaseProvider).from('chat_messages').insert({
        'sender_id': currentUser.id,
        'receiver_id': widget.receiverId,
        'content': text,
      });
      
      // Auto-scroll to bottom
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.receiverId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Chat'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => messages.isEmpty 
                ? _buildEmptyChat(context)
                : _buildMessageList(context, messages, currentUser?.id),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, List messages, String? currentUserId) {
    // Reverse list for better performance with scroll controller
    final reversedMessages = messages.reversed.toList();
    
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(24),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final message = reversedMessages[index];
        final isMe = message['sender_id'] == currentUserId;
        
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
            ),
            child: Text(
              message['content'],
              style: TextStyle(
                color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            elevation: 0,
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
