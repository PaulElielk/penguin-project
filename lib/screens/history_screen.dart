import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.history, color: Colors.teal),
              title: Text('Transaction $index'),
              subtitle: Text('Details of transaction $index'),
              trailing: Text('-\$50'),
            ),
          );
        },
      ),
    );
  }
}
