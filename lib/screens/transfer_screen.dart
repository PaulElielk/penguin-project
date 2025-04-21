import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class TransferScreen extends StatefulWidget {
  final String userId;

  TransferScreen({required this.userId});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  bool isSenderAgent = false;
  bool isReceiverAgent = false;
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  int? selectedReceiverId;

  @override
  void initState() {
    super.initState();
    _checkAgentStatus();
  }

  Future<void> _checkAgentStatus() async {
    try {
      // Check sender agent status
      final senderResponse = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (senderResponse.statusCode == 200) {
        final senderData = jsonDecode(senderResponse.body);
        setState(() {
          isSenderAgent =
              senderData['is_agent'] == 1 || senderData['is_agent'] == true;
        });
      }

      // Check receiver agent status when selected
      if (selectedReceiverId != null) {
        final receiverResponse = await http.get(
          Uri.parse('${Config.apiUrl}/users/$selectedReceiverId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (receiverResponse.statusCode == 200) {
          final receiverData = jsonDecode(receiverResponse.body);
          setState(() {
            isReceiverAgent =
                receiverData['is_agent'] == 1 ||
                receiverData['is_agent'] == true;
          });
        }
      }
    } catch (e) {
      print('Error checking agent status: $e');
    }
  }

  Widget _buildTransferForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Amount to Send',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),

          // Only show fees if neither sender nor receiver is an agent
          if (!isSenderAgent && !isReceiverAgent)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transfer Fee (1%):'),
                  Text(
                    '\$${_calculateFees().toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_calculateTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateFees() {
    if (isSenderAgent || isReceiverAgent) {
      return 0.0;
    }
    final amount = double.tryParse(amountController.text) ?? 0.0;
    return amount * 0.01;
  }

  double _calculateTotal() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    return amount + _calculateFees();
  }

  // Update receiver selection to check agent status
  void _onReceiverSelected(int receiverId) {
    setState(() {
      selectedReceiverId = receiverId;
    });
    _checkAgentStatus(); // Check if new receiver is an agent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer Money')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildTransferForm(),
      ),
    );
  }
}
