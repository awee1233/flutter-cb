import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/side_menu.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  final bool showAppBar;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.showAppBar = true,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _baseUrl = 'http://192.168.56.1:8000/api';

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
    }
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadProviders();
    await _loadChatHistory();
  }

  Future<void> _loadProviders() async {
    final chatProvider = Provider.of<ChatProviderModel>(context, listen: false);
    await chatProvider.loadProviders();
  }

  Future<void> _loadChatHistory() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await http.get(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Chat history response: ${response.statusCode}');
      print('Chat history body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> history = data['chat_history'] ?? [];

          setState(() {
            _messages.clear();
            for (var chat in history) {
              // Add user message
              _messages.add(ChatMessage(
                message: chat['message'] ?? '',
                isUser: true,
                timestamp:
                    chat['created_at'] ?? DateTime.now().toIso8601String(),
              ));

              // Add bot response if it exists
              if (chat['response'] != null) {
                _messages.add(ChatMessage(
                  message: chat['response'],
                  isUser: false,
                  timestamp:
                      chat['created_at'] ?? DateTime.now().toIso8601String(),
                ));
              }
            }
            _isLoading = false;
          });
          _scrollToBottom();
        } else {
          throw Exception(data['message'] ?? 'Failed to load chat history');
        }
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      print('Error loading chat history: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isUser: true,
        timestamp: DateTime.now().toIso8601String(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final chatProvider =
          Provider.of<ChatProviderModel>(context, listen: false);

      if (chatProvider.selectedProvider == null) {
        throw Exception('No chat provider selected');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'provider_id': chatProvider.selectedProvider!['id'],
        }),
      );

      print('Send message response: ${response.statusCode}');
      print('Send message body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['chat'] != null) {
          setState(() {
            _isTyping = false;
            if (data['chat']['response'] != null) {
              _messages.add(ChatMessage(
                message: data['chat']['response'],
                isUser: false,
                timestamp: data['chat']['created_at'] ??
                    DateTime.now().toIso8601String(),
              ));
            }
          });
          _scrollToBottom();
        } else {
          throw Exception(data['message'] ?? 'Failed to get response');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get response');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          message: 'Error: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now().toIso8601String(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProviderModel>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: const Text(
                'Chat',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                PopupMenuButton<Map<String, dynamic>>(
                  icon: const Icon(Icons.swap_horiz, color: Colors.black),
                  tooltip: 'Select Provider',
                  onSelected: (provider) {
                    chatProvider.selectProvider(provider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to ${provider['name']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context) {
                    return chatProvider.providers.map((provider) {
                      return PopupMenuItem<Map<String, dynamic>>(
                        value: provider,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: provider == chatProvider.selectedProvider
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(provider['name'] as String),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            )
          : null,
      drawer: widget.showAppBar ? const SideMenu() : null,
      body: Column(
        children: [
          if (chatProvider.selectedProvider != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Using ${chatProvider.selectedProvider!['name']}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message.message,
                  isUser: message.isUser,
                  timestamp: message.timestamp,
                );
              },
            ),
          ),
          if (_isTyping) const TypingIndicator(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: _handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
