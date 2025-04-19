import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/main.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("ยังไม่มีผู้ใช้งานเข้าสู่ระบบ")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFAED6AE),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['name'] ?? 'ไม่มีชื่อ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _infoRow("Name", data['name']),
                  _divider(),

                  _infoRow("Password", "********"),
                  _divider(),

                  _infoRow("Email", data['email']),
                  _divider(),

                  _infoRow("Phone", data['phone']),
                  _divider(),

                  _infoRow("Location", data['location']),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      
                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAED6AE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value ?? "-", style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 30, color: Colors.black);
  }
}
