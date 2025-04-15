import 'package:flutter/material.dart';

class RDVFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create RDV')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'RDV Title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Details'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save RDV to backend or local storage
              },
              child: Text('Create RDV'),
            ),
          ],
        ),
      ),
    );
  }
}
