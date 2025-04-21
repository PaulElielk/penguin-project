import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> merchants = [];
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      print('Starting to fetch data...'); // Debug log
      await Future.wait([_fetchUsers(), _fetchMerchants(), _fetchAgents()]);
      print('Data fetch completed'); // Debug log
    } catch (e) {
      print('Error in _loadData: $e'); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error refreshing data')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/admin/users'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Users API Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() => users = List<Map<String, dynamic>>.from(data));
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    }
  }

  Future<void> _fetchMerchants() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/admin/merchants'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Merchants API Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() => merchants = List<Map<String, dynamic>>.from(data));
      } else {
        throw Exception('Failed to load merchants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching merchants: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading merchants: $e')));
    }
  }

  Future<void> _fetchAgents() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/admin/agents'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Agents API Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() => agents = List<Map<String, dynamic>>.from(data));
      } else {
        throw Exception('Failed to load agents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agents: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading agents: $e')));
    }
  }

  Future<void> _createUser() async {
    print('Creating new user...'); // Debug log
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fnameController = TextEditingController();
    final lnameController = TextEditingController();
    final phoneController = TextEditingController();
    final balanceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create User Account'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: fnameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: lnameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: balanceController,
                      decoration: InputDecoration(labelText: 'Initial Balance'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(value!) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final response = await http.post(
                        Uri.parse('${Config.apiUrl}/admin/users'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'user_email': emailController.text,
                          'user_password': passwordController.text,
                          'fname': fnameController.text,
                          'lname': lnameController.text,
                          'phone_number': phoneController.text,
                          'balance': double.parse(balanceController.text),
                        }),
                      );
                      if (response.statusCode == 201) {
                        Navigator.pop(context, true);
                      } else {
                        throw Exception('Failed to create user');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating user: $e')),
                      );
                    }
                  }
                },
                child: Text('Create'),
              ),
            ],
          ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _createMerchant() async {
    print('Creating new merchant...'); // Debug log
    final formKey = GlobalKey<FormState>();
    final businessNameController = TextEditingController();
    final businessTypeController = TextEditingController();
    final businessAddressController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create Merchant Account'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: businessNameController,
                      decoration: InputDecoration(labelText: 'Business Name'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: businessTypeController,
                      decoration: InputDecoration(labelText: 'Business Type'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: businessAddressController,
                      decoration: InputDecoration(
                        labelText: 'Business Address',
                      ),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final response = await http.post(
                        Uri.parse('${Config.apiUrl}/admin/merchants'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'business_name': businessNameController.text,
                          'business_type': businessTypeController.text,
                          'business_address': businessAddressController.text,
                          'user_email': emailController.text,
                          'user_password': passwordController.text,
                          'phone_number': phoneController.text,
                          'balance': 0.0, // Add initial balance
                        }),
                      );

                      print(
                        'Response status: ${response.statusCode}',
                      ); // Debug log
                      print('Response body: ${response.body}'); // Debug log

                      if (response.statusCode == 201) {
                        Navigator.pop(context, true);
                      } else {
                        throw Exception(
                          'Failed to create merchant: ${response.body}',
                        );
                      }
                    } catch (e) {
                      print('Error creating merchant: $e'); // Debug log
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating merchant: $e')),
                      );
                    }
                  }
                },
                child: Text('Create'),
              ),
            ],
          ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _createAgent() async {
    final formKey = GlobalKey<FormState>();
    final businessNameController = TextEditingController();
    final businessAddressController = TextEditingController();
    int? selectedUserId;
    List<Map<String, dynamic>> availableUsers = [];

    // Fetch available users
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/admin/available-users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        availableUsers = List<Map<String, dynamic>>.from(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      print('Error fetching available users: $e');
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Create Agent Account'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedUserId,
                      hint: Text('Select User'),
                      items:
                          availableUsers.map<DropdownMenuItem<int>>((user) {
                            return DropdownMenuItem<int>(
                              value: user['user_id'] as int,
                              child: Text(
                                '${user['fname']} ${user['lname']} (${user['phone_number']})',
                              ),
                            );
                          }).toList(),
                      onChanged: (value) => selectedUserId = value,
                      validator:
                          (value) =>
                              value == null ? 'Please select a user' : null,
                    ),
                    TextFormField(
                      controller: businessNameController,
                      decoration: InputDecoration(labelText: 'Business Name'),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: businessAddressController,
                      decoration: InputDecoration(
                        labelText: 'Business Address',
                      ),
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      // Find the selected user's phone number
                      final selectedUser = availableUsers.firstWhere(
                        (user) => user['user_id'] == selectedUserId,
                      );

                      final response = await http.post(
                        Uri.parse('${Config.apiUrl}/admin/agents'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'business_name': businessNameController.text,
                          'business_address': businessAddressController.text,
                          'phone_number':
                              selectedUser['phone_number'], // Use user's phone number
                          'user_id': selectedUserId,
                        }),
                      );

                      if (response.statusCode == 201) {
                        Navigator.pop(context, true);
                      } else {
                        throw Exception('Failed to create agent');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating agent: $e')),
                      );
                    }
                  }
                },
                child: Text('Create'),
              ),
            ],
          ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    try {
      final userId = user['user_id'];
      print('Attempting to delete user with ID: $userId'); // Debug log

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/admin/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete response status: ${response.statusCode}'); // Debug log
      print('Delete response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        setState(() {
          users.removeWhere((u) => u['user_id'] == userId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User deleted successfully')));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to delete user');
      }
    } catch (e) {
      print('Error during delete: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Add this line - specifies number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Merchants'),
              Tab(text: 'Agents'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          // Wrap FAB in Builder
          builder:
              (context) => FloatingActionButton(
                onPressed: () {
                  // Get tab index using the correct context
                  final tabController = DefaultTabController.of(context);
                  if (tabController != null) {
                    final index = tabController.index;
                    print('Selected tab index: $index'); // Debug log

                    switch (index) {
                      case 0:
                        _createUser();
                        break;
                      case 1:
                        _createMerchant();
                        break;
                      case 2:
                        _createAgent();
                        break;
                    }
                  }
                },
                child: Icon(Icons.add),
                tooltip: 'Create New',
              ),
        ),
        body: TabBarView(
          children: [_buildUserList(), _buildMerchantList(), _buildAgentList()],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${user['fname']} ${user['lname']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['user_email']),
                Text('Phone: ${user['phone_number']}'),
                Text('Balance: \$${user['balance']}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(child: Text('Edit'), value: 'edit'),
                    PopupMenuItem(
                      child: Text('Delete'),
                      value: 'delete',
                      textStyle: TextStyle(color: Colors.red),
                    ),
                  ],
              onSelected: (value) async {
                if (value == 'edit') {
                  final formKey = GlobalKey<FormState>();
                  final fnameController = TextEditingController(
                    text: user['fname'],
                  );
                  final lnameController = TextEditingController(
                    text: user['lname'],
                  );
                  final phoneController = TextEditingController(
                    text: user['phone_number'],
                  );
                  final balanceController = TextEditingController(
                    text: user['balance'].toString(),
                  );

                  final result = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Edit User'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: fnameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: lnameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: balanceController,
                                  decoration: InputDecoration(
                                    labelText: 'Balance',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return 'Required';
                                    if (double.tryParse(value!) == null)
                                      return 'Invalid number';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  try {
                                    final response = await http.put(
                                      Uri.parse(
                                        '${Config.apiUrl}/admin/users/${user['user_id']}',
                                      ),
                                      headers: {
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        'fname': fnameController.text,
                                        'lname': lnameController.text,
                                        'phone_number': phoneController.text,
                                        'balance': double.parse(
                                          balanceController.text,
                                        ),
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      Navigator.pop(context, true);
                                    } else {
                                      throw Exception('Failed to update user');
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating user: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text('Update'),
                            ),
                          ],
                        ),
                  );

                  if (result == true) {
                    _loadData();
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete ${user['fname']} ${user['lname']}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    await _deleteUser(user);
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMerchantList() {
    return ListView.builder(
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final merchant = merchants[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(merchant['business_name']),
            subtitle: Text(
              '${merchant['business_type']} - ${merchant['business_address']}',
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(child: Text('Edit'), value: 'edit'),
                    PopupMenuItem(child: Text('Delete'), value: 'delete'),
                  ],
              onSelected: (value) async {
                if (value == 'edit') {
                  final formKey = GlobalKey<FormState>();
                  final businessNameController = TextEditingController(
                    text: merchant['business_name'],
                  );
                  final businessTypeController = TextEditingController(
                    text: merchant['business_type'],
                  );
                  final businessAddressController = TextEditingController(
                    text: merchant['business_address'],
                  );

                  final result = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Edit Merchant'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: businessNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Name',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: businessTypeController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Type',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: businessAddressController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Address',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  try {
                                    final response = await http.put(
                                      Uri.parse(
                                        '${Config.apiUrl}/admin/merchants/${merchant['merchant_id']}',
                                      ),
                                      headers: {
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        'business_name':
                                            businessNameController.text,
                                        'business_type':
                                            businessTypeController.text,
                                        'business_address':
                                            businessAddressController.text,
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      Navigator.pop(context, true);
                                    } else {
                                      throw Exception(
                                        'Failed to update merchant',
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating merchant: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text('Update'),
                            ),
                          ],
                        ),
                  );

                  if (result == true) {
                    _loadData();
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete this merchant?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    try {
                      final response = await http.delete(
                        Uri.parse(
                          '${Config.apiUrl}/admin/merchants/${merchant['merchant_id']}',
                        ),
                      );
                      if (response.statusCode == 200) {
                        _loadData();
                      } else {
                        throw Exception('Failed to delete merchant');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting merchant: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgentList() {
    return ListView.builder(
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(agent['business_name']),
            subtitle: Text(agent['business_address']),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(child: Text('Edit'), value: 'edit'),
                    PopupMenuItem(child: Text('Delete'), value: 'delete'),
                  ],
              onSelected: (value) async {
                if (value == 'edit') {
                  final formKey = GlobalKey<FormState>();
                  final businessNameController = TextEditingController(
                    text: agent['business_name'],
                  );
                  final businessAddressController = TextEditingController(
                    text: agent['business_address'],
                  );

                  final result = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Edit Agent'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: businessNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Name',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                                TextFormField(
                                  controller: businessAddressController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Address',
                                  ),
                                  validator:
                                      (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Required'
                                              : null,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  try {
                                    final response = await http.put(
                                      Uri.parse(
                                        '${Config.apiUrl}/admin/agents/${agent['agent_id']}',
                                      ),
                                      headers: {
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        'business_name':
                                            businessNameController.text,
                                        'business_address':
                                            businessAddressController.text,
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      Navigator.pop(context, true);
                                    } else {
                                      throw Exception('Failed to update agent');
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating agent: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text('Update'),
                            ),
                          ],
                        ),
                  );

                  if (result == true) {
                    _loadData();
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete this agent?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    try {
                      final response = await http.delete(
                        Uri.parse(
                          '${Config.apiUrl}/admin/agents/${agent['agent_id']}',
                        ),
                      );
                      if (response.statusCode == 200) {
                        _loadData();
                      } else {
                        throw Exception('Failed to delete agent');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting agent: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
