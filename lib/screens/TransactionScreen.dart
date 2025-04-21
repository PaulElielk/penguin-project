import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';

class TransactionScreen extends StatefulWidget {
  final int senderId;
  final Map<String, dynamic>? qrData;

  TransactionScreen({required this.senderId, this.qrData});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountSendController = TextEditingController();
  final TextEditingController amountReceiveController = TextEditingController();

  Map<String, dynamic>? receiverData;
  bool isSearching = false;
  bool isReceiverAgent = false;
  bool isSenderAgent = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_onPhoneNumberChanged);
    _checkSenderAgentStatus();

    // If QR data is provided, pre-fill the phone number and search for receiver
    if (widget.qrData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phoneNumber = widget.qrData!['phoneNumber'];
        if (phoneNumber != null) {
          phoneController.text = phoneNumber;
          searchReceiver(phoneNumber);
        }
      });
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    amountSendController.dispose();
    amountReceiveController.dispose();
    super.dispose();
  }

  void _onPhoneNumberChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      final phoneNumber = phoneController.text;
      if (phoneNumber.length >= 10) {
        searchReceiver(phoneNumber);
      }
    });
  }

  Future<void> _checkSenderAgentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.senderId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isSenderAgent = data['is_agent'] == 1 || data['is_agent'] == true;
        });
      }
    } catch (e) {
      print('Error checking sender agent status: $e');
    }
  }

  Future<void> searchReceiver(String phoneNumber) async {
    setState(() {
      isSearching = true;
      receiverData = null;
      isReceiverAgent = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${Config.apiUrl}/users/search?phone_number=$phoneNumber&sender_id=${widget.senderId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final agentCheckResponse = await http.get(
          Uri.parse('${Config.apiUrl}/users/${data['user_id']}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (agentCheckResponse.statusCode == 200) {
          final agentData = jsonDecode(agentCheckResponse.body);
          setState(() {
            receiverData = data;
            isReceiverAgent =
                agentData['is_agent'] == 1 || agentData['is_agent'] == true;
          });

          if (amountSendController.text.isNotEmpty) {
            _updateAmounts(amountSendController.text, true);
          }
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      print('Error searching user: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching user: $e')));
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> makeTransaction() async {
    if (receiverData!['user_id'] == widget.senderId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot send money to yourself'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amountSendController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter an amount')));
      return;
    }

    try {
      final amount = double.parse(amountSendController.text);
      if (amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
        return;
      }

      final fees = (isSenderAgent || isReceiverAgent) ? 0 : amount * 0.01;
      final receiveAmount = amount - fees;

      final proceed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Confirm Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount to Send: \$${amount.toStringAsFixed(2)}'),
                  Text('Fees: \$${fees.toStringAsFixed(2)}'),
                  Text('Receiver Gets: \$${receiveAmount.toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Proceed'),
                ),
              ],
            ),
      );

      if (proceed != true) return;

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/users/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': widget.senderId,
          'receiver_id': receiverData!['user_id'],
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final amount = double.parse(amountSendController.text);
        final receiverName =
            '${receiverData!['fname']} ${receiverData!['lname']}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaction successful!\n'
              'Sent \$${amount.toStringAsFixed(2)} to $receiverName',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
          arguments: {'userId': widget.senderId},
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: ${errorData['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> pickContact() async {
    try {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Permission denied')));
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No contacts found')));
        return;
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Select Contact'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, i) {
                    final contact = contacts[i];
                    return ListTile(
                      title: Text(contact.displayName),
                      subtitle: Text(
                        contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : 'No number',
                      ),
                      onTap: () async {
                        if (contact.phones.isNotEmpty) {
                          String phoneNumber = contact.phones.first.number;
                          phoneNumber = phoneNumber.replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );

                          setState(() {
                            phoneController.text = phoneNumber;
                          });

                          Navigator.pop(context);

                          await Future.delayed(Duration(milliseconds: 100));

                          await searchReceiver(phoneNumber);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
      );
    } catch (e) {
      print('Error picking contact: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accessing contacts: $e')));
    }
  }

  void _updateAmounts(String value, bool isFromSendField) {
    if (value.isEmpty) {
      amountSendController.text = '';
      amountReceiveController.text = '';
      return;
    }

    try {
      double amount = double.parse(value);
      if (isFromSendField) {
        double fees = (isSenderAgent || isReceiverAgent) ? 0 : amount * 0.01;
        double receiveAmount = amount - fees;
        amountReceiveController.text = receiveAmount.toStringAsFixed(2);
      } else {
        if (isSenderAgent || isReceiverAgent) {
          amountSendController.text = amount.toStringAsFixed(2);
        } else {
          double sendAmount = amount / 0.99;
          amountSendController.text = sendAmount.toStringAsFixed(2);
        }
      }
    } catch (e) {
      print('Error parsing amount: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Receiver Phone Number',
                border: OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.contact_phone),
                      onPressed: pickContact,
                      tooltip: 'Pick from contacts',
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            if (isSearching)
              Center(child: CircularProgressIndicator())
            else if (receiverData != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receiver Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Name: ${receiverData!['fname']} ${receiverData!['lname']}',
                      ),
                      Text('Phone: ${receiverData!['phone_number']}'),
                      if (isReceiverAgent)
                        Text(
                          'Agent Account (No fees apply)',
                          style: TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            if (!isSenderAgent && !isReceiverAgent) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountSendController,
                      decoration: InputDecoration(
                        labelText: 'Amount to Send',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                        helperText: 'Including 1% fees',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => _updateAmounts(value, true),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: amountReceiveController,
                      decoration: InputDecoration(
                        labelText: 'Amount to Receive',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                        helperText: 'After 1% fees',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => _updateAmounts(value, false),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: amountSendController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                  helperText: 'No fees apply',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  amountReceiveController.text = value;
                },
              ),
            ],

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: receiverData != null ? makeTransaction : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Send Money', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
