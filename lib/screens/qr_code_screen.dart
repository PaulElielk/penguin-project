import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../config.dart';
import 'qr_scanner_screen.dart';

class QRCodeScreen extends StatelessWidget {
  final int userId;
  final String fname;
  final String lname;
  final String phoneNumber;

  const QRCodeScreen({
    required this.userId,
    required this.fname,
    required this.lname,
    required this.phoneNumber,
  });

  String generateQRData() {
    return jsonEncode({
      'type': 'user',
      'userId': userId,
      'fname': fname,
      'lname': lname,
      'phoneNumber': phoneNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrData = {
      'userId': userId,
      'fname': fname,
      'lname': lname,
      'phoneNumber': phoneNumber,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('My QR Code'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(senderId: userId),
                ),
              );
            },
            tooltip: 'Scan QR Code',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '$fname $lname',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      phoneNumber,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    QrImageView(
                      data: generateQRData(),
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Scan to send money',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.qr_code_scanner),
                      label: Text('Scan QR Code'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => QRScannerScreen(senderId: userId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
