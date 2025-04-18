import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';

class TransactionScreen extends StatefulWidget {
  final int senderId;

  TransactionScreen({required this.senderId});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Map<String, dynamic>? receiverData;
  bool isSearching = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Add listener to phone controller
    phoneController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    // Remove listener when disposing
    phoneController.removeListener(_onPhoneNumberChanged);
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _onPhoneNumberChanged() {
    // Cancel previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set new timer
    _debounce = Timer(Duration(milliseconds: 500), () {
      final phoneNumber = phoneController.text;
      if (phoneNumber.length >= 10) {
        // Only search if number is long enough
        searchReceiver(phoneNumber);
      }
    });
  }

  Future<void> searchReceiver(String phoneNumber) async {
    setState(() {
      isSearching = true;
      receiverData = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/search?phone_number=$phoneNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          receiverData = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      print('Error searching user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching user: $e')),
      );
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> makeTransaction() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    try {
      final amount = double.parse(amountController.text);
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      print('Sending transaction:');
      print('Sender ID: ${widget.senderId}');
      print('Receiver ID: ${receiverData!['user_id']}');
      print('Amount: $amount');

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/users/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': widget.senderId,
          'receiver_id': receiverData!['user_id'],
          'amount': amount,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction successful'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(Duration(seconds: 1));

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
            content: Text(
                'Transaction failed: ${errorData['error'] ?? 'Unknown error'}'),
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
      // Request permission
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied')),
        );
        return;
      }

      // Get all contacts
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No contacts found')),
        );
        return;
      }

      // Show contact picker dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                  subtitle: Text(contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : 'No number'),
                  onTap: () async {
                    // Make onTap async
                    if (contact.phones.isNotEmpty) {
                      String phoneNumber = contact.phones.first.number;
                      // Remove any spaces or special characters
                      phoneNumber =
                          phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

                      setState(() {
                        phoneController.text = phoneNumber;
                      });

                      Navigator.pop(context); // Close dialog first

                      // Wait a brief moment before searching
                      await Future.delayed(Duration(milliseconds: 100));

                      // Search for the receiver after dialog is closed
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing contacts: $e')),
      );
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
            // Updated phone number field with contact picker
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
                    // Remove the search button since search is now automatic
                  ],
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // Receiver information card
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
                          'Name: ${receiverData!['fname']} ${receiverData!['lname']}'),
                      Text('Phone: ${receiverData!['phone_number']}'),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Amount input field
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),

            // Send button
            ElevatedButton(
              onPressed: receiverData != null
                  ? makeTransaction
                  : null, // Remove amountController.text.isNotEmpty check
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Send Money',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
