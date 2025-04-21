import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AccountScreen extends StatefulWidget {
  final int userId;

  AccountScreen({required this.userId});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fnameController.text = data['fname'];
          lnameController.text = data['lname'];
          phoneController.text = data['phone_number'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user data')));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.put(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fname': fnameController.text,
          'lname': lnameController.text,
          'phone_number': phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.apiUrl}/users/${widget.userId}/password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_password': currentPasswordController.text,
          'new_password': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        currentPasswordController.clear();
        newPasswordController.clear();
      } else {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Account')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: fnameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: lnameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _updateProfile,
                                child: Text('Update Profile'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: currentPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: newPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _changePassword,
                                child: Text('Change Password'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
