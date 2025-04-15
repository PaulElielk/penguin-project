import 'package:flutter/material.dart';
import 'package:money_transfer/main.dart'; // Import the registerUser function

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: fnameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lnameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(labelText: 'Initial Balance'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Validate fields
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    fnameController.text.isEmpty ||
                    lnameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    balanceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Call registerUser function
                try {
                  await registerUser(
                    emailController.text,
                    passwordController.text,
                    fnameController.text,
                    lnameController.text,
                    phoneController.text,
                    double.tryParse(balanceController.text) ?? 0.0,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration successful')),
                  );
                  Navigator.pop(context); // Close the screen after success
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: $e')),
                  );
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
