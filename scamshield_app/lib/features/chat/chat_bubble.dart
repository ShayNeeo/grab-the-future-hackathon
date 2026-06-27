import 'package:flutter/material.dart';
import '../../core/providers/chat_provider.dart';
import '../alert/alert_screen.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageBase64 != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      Uri.parse(
                              'data:image/jpeg;base64,${message.imageBase64}')
                          .data!
                          .contentAsBytes(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _isUser
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
              ],
            ),
          ),
          if (message.response != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AlertScreen(response: message.response!),
                  ),
                ),
                child: const Text('Xem chi tiết phân tích →'),
              ),
            ),
        ],
      ),
    );
  }
}
