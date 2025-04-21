import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:money_transfer/screens/merchant_transfer_screen.dart';
import 'package:http/http.dart' as http;
import 'package:money_transfer/config.dart';

class QRScannerScreen extends StatefulWidget {
  final int senderId;

  const QRScannerScreen({required this.senderId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (!isScanned && capture.barcodes.isNotEmpty) {
      final String? code = capture.barcodes.first.rawValue;
      if (code != null) {
        isScanned = true;
        _processQRResult(code).then((_) async {
          // Await navigation completion before resetting isScanned
          await Future.delayed(Duration(milliseconds: 500));
          isScanned = false;
        });
      }
    }
  }

  Future<void> _processQRResult(String code) async {
    try {
      final qrData = jsonDecode(code);
      print('QR Data decoded: $qrData');

      // Handle merchant QR code
      if (qrData.containsKey('merchantId') &&
          qrData.containsKey('businessName') &&
          qrData.containsKey('phoneNumber')) {
        print('Navigating to merchant transfer screen with data: $qrData');

        if (mounted) {
          await Navigator.pushReplacementNamed(
            context,
            '/merchant-transfer',
            arguments: {
              'senderId': widget.senderId,
              'merchantId': int.parse(
                qrData['merchantId'].toString(),
              ), // Ensure merchantId is parsed as int
              'businessName': qrData['businessName'],
              'phoneNumber': qrData['phoneNumber'],
              'isMerchant': true,
              'fromQR': true,
            },
          );
        }
        return;
      }

      // Handle other QR code types here
      print('QR code not recognized or missing required fields');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid QR code format')));
      }
    } catch (e) {
      print('Error processing QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing QR code')));
      }
    }
  }

  void _navigateToTransfer(Map<String, dynamic> data, bool isMerchant) {
    if (isMerchant) {
      Navigator.pushReplacementNamed(
        context,
        '/merchant-transfer',
        arguments: {
          'senderId': widget.senderId,
          'merchantId': data['merchant_id'],
          'businessName': data['business_name'],
          'phoneNumber': data['phone_number'],
          'isMerchant': true,
          'fromQR': true, // Make sure this is included
        },
      );
    } else {
      // For user transfers
      Navigator.pushReplacementNamed(
        context,
        '/transfer',
        arguments: {
          'userId': widget.senderId,
          'phoneNumber': data['phone_number'],
          'receiverId': data['user_id'],
          'receiverName': '${data['fname']} ${data['lname']}',
          'isAgent': data['is_agent'],
          'fromQR': true, // Add this flag
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Column(
        children: [
          Expanded(flex: 5, child: MobileScanner(onDetect: _onDetect)),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Align QR code within the frame to scan',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
