import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // Today - show time only
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
      } else if (difference.inDays < 7) {
        // Within a week
        return '${DateFormat('EEEE').format(dateTime)} ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        // More than a week ago
        return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
      }
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Invalid date';
    }
  }
}
