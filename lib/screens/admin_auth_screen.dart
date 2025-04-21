import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'dart:convert';

class AdminAuthScreen extends StatefulWidget {
  @override
  _AdminAuthScreenState createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final _adminKeyController = TextEditingController();

  Future<void> _verifyAdminKey() async {
    // Simple check for preset admin key
    if (_adminKeyController.text == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid admin key')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _adminKeyController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Admin Key'),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _verifyAdminKey, child: Text('Verify')),
            ],
          ),
        ),
      ),
    );
  }
}
