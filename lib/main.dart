import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_transfer/screens/dashboard_screen.dart';
import 'package:money_transfer/screens/history_screen.dart';
import 'package:money_transfer/screens/list_screen.dart';
import 'package:money_transfer/screens/login_screen.dart';
import 'package:money_transfer/screens/rdv_form_screen.dart';
import 'package:money_transfer/screens/register_screen.dart';
import 'package:money_transfer/screens/TransactionScreen.dart'; // Update this import
import 'package:http/http.dart' as http;
import 'config.dart';

void main() {
  runApp(const MyMobileMoneyApp());
}

class MyMobileMoneyApp extends StatelessWidget {
  const MyMobileMoneyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Money App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/history': (context) => HistoryScreen(),
        // Update this route to use TransactionScreen
        '/transfer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as int?;
          if (userId == null) {
            return Scaffold(
              body: Center(
                child: Text('Error: Missing user ID'),
              ),
            );
          }
          return TransactionScreen(senderId: userId);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || !args.containsKey('userId')) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text(
                    'Error: Missing or invalid arguments for /dashboard',
                  ),
                ),
              ),
            );
          }

          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(userId: userId),
          );
        }
        return null; // Return null for unknown routes
      },
    );
  }
}

Future<void> registerUser(
  String email,
  String password,
  String fname,
  String lname,
  String phoneNumber,
  double balance,
) async {
  final url = Uri.parse('${Config.apiUrl}/users/register');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_email': email,
      'user_password': password,
      'fname': fname,
      'lname': lname,
      'phone_number': phoneNumber,
      'balance': balance,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to register user: ${response.body}');
  }
}
