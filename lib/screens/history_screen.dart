import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:money_transfer/screens/merchant_history_Screen.dart'; // Add this import

class HistoryScreen extends StatefulWidget {
  final int userId;

  const HistoryScreen({required this.userId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> regularTransactions = [];
  List<Map<String, dynamic>> merchantTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}/transactions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Raw API Response: ${response.body}');

        setState(() {
          // Separate transactions into regular and merchant
          regularTransactions =
              data
                  .where((item) => item['is_merchant'] != 1)
                  .map<Map<String, dynamic>>(
                    (item) => _transformTransaction(item),
                  )
                  .toList();

          merchantTransactions =
              data
                  .where((item) => item['is_merchant'] == 1)
                  .map<Map<String, dynamic>>(
                    (item) => _transformTransaction(item),
                  )
                  .toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transactions: $e')));
    }
  }

  Map<String, dynamic> _transformTransaction(dynamic item) {
    final bool isMerchant = item['is_merchant'] == 1;
    String otherPartyName;

    if (isMerchant) {
      // Use business_name from the transaction record
      otherPartyName = item['business_name'] ?? 'Unknown Merchant';
    } else {
      otherPartyName =
          item['direction'] == 'sent'
              ? '${item['receiver_fname'] ?? ''} ${item['receiver_lname'] ?? ''}'
                  .trim()
              : '${item['sender_fname'] ?? ''} ${item['sender_lname'] ?? ''}'
                  .trim();
    }

    return {
      'id': item['id'],
      'sender_id': item['sender_id'],
      'receiver_id': item['receiver_id'],
      'direction': item['direction'],
      'amount': item['amount']?.toString() ?? '0',
      'fees': item['fees']?.toString() ?? '0',
      'transaction_date': item['transaction_date'],
      'other_party_name': otherPartyName.isEmpty ? 'Unknown' : otherPartyName,
      'other_party_phone': item['phone_number'] ?? 'No phone number',
      'is_merchant': isMerchant,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transaction History'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Regular Transactions'),
              Tab(text: 'Merchant Transactions'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadAllTransactions,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Regular transactions tab
            _buildTransactionList(regularTransactions),
            // Merchant transactions tab
            _buildTransactionList(merchantTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (transactions.isEmpty) {
      return Center(child: Text('No transactions found'));
    }
    return RefreshIndicator(
      onRefresh: _loadAllTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _TransactionItemCard(transaction: transactions[index]);
        },
      ),
    );
  }
}

class _TransactionItemCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionItemCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isSent = transaction['direction'] == 'sent';
    final double amount =
        double.tryParse(transaction['amount'].toString()) ?? 0.0;
    final double fees = double.tryParse(transaction['fees'].toString()) ?? 0.0;
    final bool isMerchant = transaction['is_merchant'] == 1;

    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSent ? Colors.red[100] : Colors.green[100],
          child: Icon(
            isSent ? Icons.arrow_upward : Icons.arrow_downward,
            color: isSent ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          '${isSent ? "Paid to" : "Received from"}: ${transaction['other_party_name']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction['other_party_phone'] != null)
              Text('Phone: ${transaction['other_party_phone']}'),
            Text(
              'Amount: ${amount.toStringAsFixed(2)} ${isSent ? '(+ ${fees.toStringAsFixed(2)} fees)' : ''}',
              style: TextStyle(
                color: isSent ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Date: ${DateTime.parse(transaction['transaction_date']).toLocal().toString().split('.')[0]}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing:
            isMerchant
                ? Tooltip(
                  message: 'Merchant',
                  child: Icon(Icons.store, color: Colors.blue),
                )
                : null,
      ),
    );
  }
}
