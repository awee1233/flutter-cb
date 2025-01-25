import 'package:flutter/material.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  final List<Map<String, String>> suggestions = const [
    {
      'title': 'Give me ideas',
      'subtitle': 'For what to do with my kids\' art',
    },
    {
      'title': 'Create a charter',
      'subtitle': 'To start a film club',
    },
    {
      'title': 'Analysis a PDF, Docs file',
      'subtitle': 'For what to do with my kids\' art',
    },
    {
      'title': 'Brainstorm names',
      'subtitle': 'For what to do with my kids\' art',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          'New chat',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      suggestions[index]['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      suggestions[index]['subtitle']!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            initialMessage: suggestions[index]['title'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'These are just a few examples of what I can do.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
