import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_email': emailController.text,
          'user_password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data['userId'];

        if (userId != null) {
          Navigator.pushReplacementNamed(
            context,
            '/dashboard',
            arguments: {'userId': userId},
          );
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Create Account'),
                ),
              ],
            ),
            Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Are you a merchant?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/merchant-login');
                  },
                  child: Text('Login as Merchant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
