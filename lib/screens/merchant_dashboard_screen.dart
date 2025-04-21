import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'merchant_qr_screen.dart';

class MerchantDashboardScreen extends StatefulWidget {
  final int
  merchantId; // Changed from userId to merchantId since merchant_account uses merchant_id

  MerchantDashboardScreen({required this.merchantId});

  @override
  _MerchantDashboardScreenState createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  String businessName = '';
  String businessType = '';
  String phoneNumber = '';
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Config.apiUrl}/users/merchants/${widget.merchantId}',
        ), // Updated path to match backend route
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          businessName = data['business_name'] ?? '';
          businessType = data['business_type'] ?? '';
          phoneNumber = data['phone_number'] ?? '';
          balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load merchant data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading merchant data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading merchant data: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              setState(() => isLoading = true);
              try {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MerchantQRScreen(
                          merchantId: widget.merchantId,
                          businessName: businessName,
                          phoneNumber: phoneNumber,
                        ),
                  ),
                );
                await _loadMerchantData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error showing QR code: $e')),
                );
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              await _loadMerchantData();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildDetailRow('Name', businessName),
                            _buildDetailRow('Type', businessType),
                            _buildDetailRow('Phone', phoneNumber),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
