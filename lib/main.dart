import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_transfer/screens/dashboard_screen.dart';
import 'package:money_transfer/screens/history_screen.dart';
import 'package:money_transfer/screens/admin_auth_screen.dart';
import 'package:money_transfer/screens/login_screen.dart';
import 'package:money_transfer/screens/admin_dashboard_screen.dart';
import 'package:money_transfer/screens/register_screen.dart';
import 'package:money_transfer/screens/TransactionScreen.dart'; // Update this import
import 'package:money_transfer/screens/account_screen.dart'; // Import AccountScreen
import 'package:money_transfer/screens/qr_code_screen.dart'; // Import QRCodeScreen
import 'package:money_transfer/screens/qr_scanner_screen.dart'; // Import QRScannerScreen
import 'package:http/http.dart' as http;
import 'config.dart';
import '../screens/merchant_dashboard_screen.dart';
import 'package:money_transfer/screens/merchant_login_screen.dart'; // Import MerchantLoginScreen
import 'package:money_transfer/screens/merchant_transfer_screen.dart'; // Add this import

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
        '/merchant-login': (context) => MerchantLoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/history': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as int?;
          if (userId == null) {
            return Scaffold(
              body: Center(child: Text('Error: Missing user ID')),
            );
          }
          return HistoryScreen(userId: userId);
        },
        '/transfer': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;

          final userId = args?['userId'] as int?;
          final phoneNumber = args?['phoneNumber'] as String?;

          if (userId == null) {
            return Scaffold(
              body: Center(child: Text('Error: Missing user ID')),
            );
          }

          Map<String, dynamic>? qrData;
          if (phoneNumber != null) {
            qrData = {'phoneNumber': phoneNumber};
          }

          return TransactionScreen(senderId: userId, qrData: qrData);
        },
        '/account': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as int?;
          if (userId == null) {
            return Scaffold(
              body: Center(child: Text('Error: Missing user ID')),
            );
          }
          return AccountScreen(userId: userId);
        },
        '/qr-code': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return QRCodeScreen(
            userId: args?['userId'] as int,
            fname: args?['fname'] as String,
            lname: args?['lname'] as String,
            phoneNumber: args?['phoneNumber'] as String,
          );
        },
        '/qr-scanner': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null || args['senderId'] == null) {
            return Scaffold(
              body: Center(
                child: Text('Error: Missing sender ID for QR scanner'),
              ),
            );
          }
          return QRScannerScreen(senderId: args['senderId'] as int);
        },
        '/admin': (context) => AdminDashboardScreen(),
        '/admin-panel': (context) => AdminAuthScreen(),
        '/dashboard': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return DashboardScreen(userId: args?['userId'] ?? '');
        },
        '/merchant-dashboard': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return MerchantDashboardScreen(merchantId: args?['merchantId'] ?? 0);
        },
        '/merchant-transfer': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid arguments')),
            );
          }
          return MerchantTransferScreen(
            senderId: args['senderId'] ?? 0,
            merchantId: args['merchantId'] ?? 0,
            businessName: args['businessName'] ?? '',
            phoneNumber: args['phoneNumber'] ?? '',
            isMerchant: args['isMerchant'] ?? false,
            fromQR: args['fromQR'] ?? false,
          );
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || !args.containsKey('userId')) {
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
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
