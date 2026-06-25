import 'package:flutter/material.dart';

class CravingScreen extends StatelessWidget {
  const CravingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sweet Craving')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.icecream_rounded, size: 80, color: Colors.purple.shade300),
              const SizedBox(height: 24),
              Text(
                'I want something sweet...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              _buildChatBubble(context, 
                'I understand you have a craving. Let\'s look at your sugar level first.', 
                isAI: true
              ),
              const SizedBox(height: 16),
              
              _buildChatBubble(context, 
                'Your sugar was normal at 110 mg/dL this morning, but a heavy dessert right now could trigger a spike before dinner.', 
                isAI: true
              ),
              
              const Spacer(),
              const Text('Healthy Alternatives', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildAlternativeBtn('Apple with\nPeanut Butter')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAlternativeBtn('Sugar-free\nYogurt')),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Delay craving & Drink Water'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String text, {required bool isAI}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAI ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16).copyWith(
          topLeft: isAI ? const Radius.circular(0) : const Radius.circular(16),
          bottomRight: isAI ? const Radius.circular(16) : const Radius.circular(0),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4)),
    );
  }

  Widget _buildAlternativeBtn(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
