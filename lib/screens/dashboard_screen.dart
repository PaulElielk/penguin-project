import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../screens/qr_code_screen.dart'; // Add this import

class DashboardScreen extends StatefulWidget {
  final int userId;

  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String fname = '';
  String lname = '';
  String phoneNumber = ''; // Add phoneNumber to your state variables
  double balance = 0.0;
  bool isLoading = true;
  bool isLoadingTransactions = true;
  bool isAgent = false; // Add this variable
  List<Map<String, dynamic>> transactions = [];
  Timer? _refreshTimer;

  // Add these variables at the top of the class
  DateTime? _firstTapTime;
  int _tapCount = 0;
  final int _requiredTaps = 5;
  final Duration _maxDuration = Duration(seconds: 3);

  // Add this method to handle the secret tap pattern
  void _handleSecretTap() {
    final now = DateTime.now();

    if (_firstTapTime == null) {
      _firstTapTime = now;
      _tapCount = 1;
    } else {
      // Check if we're still within the time window
      if (now.difference(_firstTapTime!) < _maxDuration) {
        _tapCount++;

        // Check if pattern is complete
        if (_tapCount == _requiredTaps) {
          // Reset pattern
          _firstTapTime = null;
          _tapCount = 0;

          // Navigate to admin panel
          Navigator.pushNamed(context, '/admin-panel');
        }
      } else {
        // Reset if too much time has passed
        _firstTapTime = now;
        _tapCount = 1;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_fetchUserData(), _fetchTransactions()]);
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fname = data['fname'] ?? '';
          lname = data['lname'] ?? '';
          phoneNumber = data['phone_number'] ?? '';
          balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
          // Convert the is_agent value to boolean
          isAgent = data['is_agent'] == 1 || data['is_agent'] == true;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data')));
      }
    }
  }

  Future<void> _fetchTransactions() async {
    if (!mounted) return;

    setState(() {
      isLoadingTransactions = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}/transactions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          transactions = List<Map<String, dynamic>>.from(data);
          isLoadingTransactions = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      if (!mounted) return;
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transactions')));
      setState(() {
        isLoadingTransactions = false;
      });
    }
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isSender = transaction['sender_id'] == widget.userId;
    final amount = double.parse(transaction['amount'].toString());
    final fees = double.parse(transaction['fees'].toString());

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        leading: Icon(
          isSender ? Icons.arrow_upward : Icons.arrow_downward,
          color: isSender ? Colors.red : Colors.green,
        ),
        title: Text(
          isSender
              ? 'Sent to ${transaction['receiver_fname']} ${transaction['receiver_lname']}'
              : 'Received from ${transaction['sender_fname']} ${transaction['sender_lname']}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateTime.parse(transaction['transaction_date']).toString()),
            if (!isAgent) // Only show fees for non-agents
              Text(
                'Fees: \$${fees.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSender ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard ${isAgent ? '(Agent)' : ''}',
        ), // Add agent indicator
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => QRCodeScreen(
                        userId: widget.userId,
                        fname: fname,
                        lname: lname,
                        phoneNumber: phoneNumber,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/account',
                arguments: {'userId': widget.userId},
              );
            },
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadInitialData),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _handleSecretTap,
        behavior: HitTestBehavior.translucent,
        child: RefreshIndicator(
          onRefresh: _loadInitialData,
          child:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAgent)
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.green.withOpacity(0.1),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Agent Account: No fees on transactions',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 16),

                          // Welcome Card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '$fname $lname',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Balance Card
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Balance',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '\$${balance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Send Money Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/transfer',
                                arguments: {'userId': widget.userId},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send),
                                SizedBox(width: 8),
                                Text(
                                  'Send Money',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Transaction History Section
                          Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          isLoadingTransactions
                              ? Center(child: CircularProgressIndicator())
                              : transactions.isEmpty
                              ? Center(
                                child: Text(
                                  'No transactions yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                              : Column(
                                children:
                                    transactions
                                        .map(_buildTransactionItem)
                                        .toList(),
                              ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
