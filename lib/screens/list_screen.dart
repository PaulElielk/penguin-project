import 'package:flutter/material.dart';

class ListScreen extends StatelessWidget {
  final List<String> items;

  ListScreen({required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Handle delete logic
              },
            ),
          );
        },
      ),
    );
  }
}
