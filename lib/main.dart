import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_transfer/screens/dashboard_screen.dart';
import 'package:money_transfer/screens/history_screen.dart';
import 'package:money_transfer/screens/list_screen.dart';
import 'package:money_transfer/screens/login_screen.dart';
import 'package:money_transfer/screens/rdv_form_screen.dart';
import 'package:money_transfer/screens/register_screen.dart';
import 'package:money_transfer/screens/transfer_screen.dart';
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
        '/dashboard': (context) => DashboardScreen(),
        '/register': (context) => RegisterScreen(),
        '/history': (context) => HistoryScreen(),
        '/transfer': (context) => TransferScreen(),
      },
    );
  }
}

class User {
  final String username;
  final String role;

  User(this.username, this.role);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? loggedInUser;

  // Functionality: Log In
  void _logIn() {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Validate credentials
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login successful')),
                  );
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushNamed(
                      context, '/dashboard'); // Redirect to dashboard
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid credentials')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Login failed: $e')),
                );
              }
            },
            child: Text('Log In'),
          ),
        ],
      ),
    );
  }

  // Functionality: Register Normal User
  Future<void> _registerNormalUser() async {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController fnameController = TextEditingController();
    TextEditingController lnameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register Normal User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: fnameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lnameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(labelText: 'Initial Balance'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty &&
                  fnameController.text.isNotEmpty &&
                  lnameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                await registerUser(
                  emailController.text,
                  passwordController.text,
                  fnameController.text,
                  lnameController.text,
                  phoneController.text,
                  double.tryParse(balanceController.text) ?? 0.0,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mobile Money App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: _logIn, child: Text('Log In')),
            ElevatedButton(
              onPressed: _registerNormalUser,
              child: Text('Register Normal User'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> registerUser(String email, String password, String fname,
    String lname, String phoneNumber, double balance) async {
  try {
    debugPrint('Registering user: $email');
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

    if (response.statusCode == 201) {
      print('User registered successfully');
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Failed to register user: $e');
  }
}
