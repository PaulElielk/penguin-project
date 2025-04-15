import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String fname = "John"; // Replace with actual data
  final String lname = "Doe"; // Replace with actual data
  final double balance = 1000.0; // Replace with actual data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Text(
              'Welcome, $fname $lname',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // Balance Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$$balance',
                      style: TextStyle(fontSize: 18, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Send Money Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/transfer');
              },
              icon: Icon(Icons.send, color: Colors.white),
              label: Text('Send Money'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
