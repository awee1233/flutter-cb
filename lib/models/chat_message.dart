class ChatMessage {
  final String message;
  final bool isUser;
  final String timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String messageContent = '';

    if (json['message'] != null) {
      messageContent = json['message'];
    } else if (json['response'] != null) {
      messageContent = json['response'];
    } else if (json['chat'] != null && json['chat']['response'] != null) {
      messageContent = json['chat']['response'];
    } else if (json['chat'] != null && json['chat']['message'] != null) {
      messageContent = json['chat']['message'];
    }

    if (messageContent.isEmpty) {
      print('Warning: Empty message content from JSON: $json');
      messageContent = 'Error: Message content not found';
    }

    return ChatMessage(
      message: messageContent,
      isUser: json['isUser'] ?? json['is_user'] ?? false,
      timestamp: json['timestamp'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ChatMessage{message: $message, isUser: $isUser, timestamp: $timestamp}';
  }
}
