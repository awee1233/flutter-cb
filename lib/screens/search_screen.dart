import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Give me an idea for writing a paragraph for Hawaii...',
    'Analysis this PDF file and give me the result by a cha...',
    'Where is Hawaii and how can I go there and by whic...',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _recentSearches.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _recentSearches[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.history),
            onTap: () {
              _searchController.text = _recentSearches[index];
            },
          );
        },
      ),
    );
  }
}
