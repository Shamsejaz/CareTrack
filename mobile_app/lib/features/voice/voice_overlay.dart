import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../core/providers/auth_provider.dart';

enum VoiceState { idle, listening, processing, responding, error }

class VoiceAssistantOverlay extends ConsumerStatefulWidget {
  const VoiceAssistantOverlay({super.key});

  @override
  ConsumerState<VoiceAssistantOverlay> createState() => _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends ConsumerState<VoiceAssistantOverlay> with SingleTickerProviderStateMixin {
  VoiceState _state = VoiceState.idle;
  String _displayText = "How can I help you today?";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _state = VoiceState.listening;
      _displayText = "Listening...";
    });
    _pulseController.repeat(reverse: true);
    
    // Simulate recording delay before sending to backend
    Future.delayed(const Duration(seconds: 3), () {
      _stopListeningAndProcess();
    });
  }

  void _stopListeningAndProcess() async {
    _pulseController.stop();
    setState(() {
      _state = VoiceState.processing;
      _displayText = "Processing...";
    });

    final supabase = ref.read(supabaseProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final session = supabase.auth.currentSession;
      if (session == null) throw Exception("No active session");

      // For testing, we send a hardcoded text payload since recording audio natively in the emulator is complex.
      // The Edge Function natively handles either `text` or `audio_base64`.
      const simulatedText = "I just took my Metformin";

      final response = await supabase.functions.invoke(
        'ai-voice-assistant',
        body: { 'text': simulatedText },
      );

      final data = response.data;
      if (data == null) throw Exception("No response from AI");

      setState(() {
        _state = VoiceState.responding;
        _displayText = data['response_text'] ?? "I've handled that for you.";
      });

      // Close overlay automatically after responding
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _state == VoiceState.responding) {
          Navigator.of(context).pop();
        }
      });

    } catch (e) {
      setState(() {
        _state = VoiceState.error;
        _displayText = "Sorry, I had trouble understanding that.";
      });
      print("Voice Assistant Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _displayText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 48),
          
          GestureDetector(
            onTapDown: (_) {
              if (_state == VoiceState.idle || _state == VoiceState.error) {
                _startListening();
              }
            },
            onTapUp: (_) {
               // In a real PTT, releasing the button might trigger the upload
               // Here we let the mock 3 second timer handle it for easier demo flow
            },
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _state == VoiceState.listening ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _state == VoiceState.listening 
                    ? Theme.of(context).colorScheme.primary 
                    : (_state == VoiceState.error ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary),
                  boxShadow: [
                    BoxShadow(
                      color: (_state == VoiceState.listening ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _state == VoiceState.listening ? Icons.mic_rounded : 
                  _state == VoiceState.processing ? Icons.hourglass_empty_rounded :
                  _state == VoiceState.error ? Icons.refresh_rounded : Icons.mic_none_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_state == VoiceState.idle || _state == VoiceState.error)
            Text(
              "Tap to speak",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
