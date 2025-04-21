import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class MerchantTransferScreen extends StatefulWidget {
  final int senderId;
  final int merchantId;
  final String businessName;
  final String phoneNumber;
  final bool isMerchant;
  final bool fromQR;

  const MerchantTransferScreen({
    Key? key,
    required this.senderId,
    required this.merchantId,
    required this.businessName,
    required this.phoneNumber,
    this.isMerchant = false,
    this.fromQR = false,
  }) : super(key: key);

  @override
  _MerchantTransferScreenState createState() => _MerchantTransferScreenState();
}

class _MerchantTransferScreenState extends State<MerchantTransferScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('MerchantTransferScreen initialized with:');
    print('senderId: ${widget.senderId}');
    print('merchantId: ${widget.merchantId}');
    print('businessName: ${widget.businessName}');
    print('phoneNumber: ${widget.phoneNumber}');
    print('isMerchant: ${widget.isMerchant}');
    print('fromQR: ${widget.fromQR}');
  }

  Future<void> _makeTransfer() async {
    if (_amountController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      print(
        'Making transfer with merchantId: ${widget.merchantId}',
      ); // Debug log
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/users/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': widget.senderId,
          'receiver_id': widget.merchantId, // Make sure this is the merchant_id
          'amount': double.parse(_amountController.text),
          'is_merchant_transaction':
              true, // Updated to match backend expectation
          'business_name': widget.businessName,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment successful')));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Transfer failed');
      }
    } catch (e) {
      print('Transfer error: $e'); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transfer failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay Merchant'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.businessName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    SizedBox(height: 8),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '0% Transaction Fee',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _makeTransfer,
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Confirm Payment'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
