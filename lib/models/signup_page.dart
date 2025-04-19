import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/main.dart';
import 'package:login/models/MainScaffold.dart';
import 'package:login/models/home_page.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  SignUpPage({super.key});

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

            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: _inputDecoration("Name", Icons.person),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration("Password", Icons.lock),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: _inputDecoration("Email", Icons.email),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              decoration: _inputDecoration("Phone", Icons.phone),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: locationController,
              decoration: _inputDecoration("Location", Icons.location_on),
            ),
            const SizedBox(height: 15),

            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final phone = phoneController.text.trim();
                final location = locationController.text.trim();

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("เกิดข้อผิดพลาด"),
                      content: const Text("กรุณากรอกชื่อ, อีเมล และรหัสผ่าน"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                        'name': name,
                        'email': email,
                        'phone': phone.isNotEmpty ? phone : '',
                        'location': location.isNotEmpty ? location : '',
                        'coin': 0,
                        'tree': 0,
                        'lastTreeUpdate': Timestamp.now(),
                      });

                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => MainScaffold()),
                  );
                } on FirebaseAuthException catch (e) {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Sign Up Failed"),
                      content: Text(e.message ?? "Unknown error"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
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
