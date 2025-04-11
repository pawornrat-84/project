import 'package:flutter/material.dart';
import 'package:login/main.dart';
import 'package:login/models/home_page.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD9F0D9), Color(0xFF9FC79F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assests/avatar.jpg'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 30),

            // Name
            TextField(
              controller: nameController,
              decoration: _inputDecoration("Name", Icons.person),
            ),
            const SizedBox(height: 10),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration("Password", Icons.lock),
            ),
            const SizedBox(height: 10),

            // Email
            TextField(
              controller: emailController,
              decoration: _inputDecoration("Email", Icons.email),
            ),
            const SizedBox(height: 10),

            // Phone
            TextField(
              controller: phoneController,
              decoration: _inputDecoration("Phone", Icons.phone),
            ),
            const SizedBox(height: 10),

            // Location
            TextField(
              controller: locationController,
              decoration: _inputDecoration("Location", Icons.location_on),
            ),
            const SizedBox(height: 15),

            // Sign Up Button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text('Sign up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('BACK'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
