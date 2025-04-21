import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class MerchantQRScreen extends StatelessWidget {
  final int merchantId;
  final String businessName;
  final String phoneNumber;

  const MerchantQRScreen({
    Key? key,
    required this.merchantId,
    required this.businessName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create the merchant data object with simplified format
    final merchantData = {
      'merchantId': merchantId,
      'businessName': businessName,
      'phoneNumber': phoneNumber,
      'isMerchant': true,
    };

    // Convert directly to JSON string
    final qrData = jsonEncode(merchantData);

    print('Generated QR Data: $qrData'); // Debug log

    return Scaffold(
      appBar: AppBar(title: Text('Merchant QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phoneNumber,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
