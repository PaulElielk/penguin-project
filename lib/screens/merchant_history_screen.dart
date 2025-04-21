import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class MerchantHistoryScreen extends StatefulWidget {
  final int userId;

  const MerchantHistoryScreen({required this.userId});

  @override
  _MerchantHistoryScreenState createState() => _MerchantHistoryScreenState();
}

class _MerchantHistoryScreenState extends State<MerchantHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMerchantTransactions();
  }

  Future<void> _loadMerchantTransactions() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Config.apiUrl}/users/${widget.userId}/merchant-transactions',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Raw Merchant Transactions: ${response.body}');

        setState(() {
          transactions =
              data.map<Map<String, dynamic>>((item) {
                return {
                  'id': item['id'],
                  'merchant_id': item['merchant_id'],
                  'business_name': item['business_name'],
                  'amount': item['amount']?.toString() ?? '0',
                  'fees': item['fees']?.toString() ?? '0',
                  'transaction_date': item['transaction_date'],
                  'status': item['status'],
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load merchant transactions');
      }
    } catch (e) {
      print('Error loading merchant transactions: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading merchant transactions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMerchantTransactions,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? Center(child: Text('No merchant transactions yet'))
              : RefreshIndicator(
                onRefresh: _loadMerchantTransactions,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return _MerchantTransactionCard(
                      transaction: transactions[index],
                    );
                  },
                ),
              ),
    );
  }
}

class _MerchantTransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _MerchantTransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final double amount =
        double.tryParse(transaction['amount'].toString()) ?? 0.0;
    final double fees = double.tryParse(transaction['fees'].toString()) ?? 0.0;

    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.store, color: Colors.blue),
        ),
        title: Text(
          transaction['business_name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${amount.toStringAsFixed(2)} (+ ${fees.toStringAsFixed(2)} fees)',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            Text(
              'Date: ${DateTime.parse(transaction['transaction_date']).toLocal().toString().split('.')[0]}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Status: ${transaction['status']}',
              style: TextStyle(
                fontSize: 12,
                color:
                    transaction['status'] == 'completed'
                        ? Colors.green
                        : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
