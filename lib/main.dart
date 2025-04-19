import 'package:flutter/material.dart';
import 'package:login/models/MainScaffold.dart';
import 'package:login/models/home_page.dart';
import 'models/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login UI',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  Future<void> loginWithEmailAndPassword(BuildContext context) async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

 
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("ข้อมูลไม่ครบถ้วน"),
              content: const Text("กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วน"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ตกลง"),
                ),
              ],
            ),
      );
      return; 
    }

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => MainScaffold()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';

      if (e.code == 'user-not-found') {
        message = 'ไม่พบบัญชีผู้ใช้นี้';
      } else if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      }


      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("เข้าสู่ระบบล้มเหลว"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ตกลง"),
                ),
              ],
            ),
      );
    }
  }

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

            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {

                loginWithEmailAndPassword(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 15,
                ),
              ),
              child: const Text('LOGIN'),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 75,
                  vertical: 15,
                ),
              ),
              child: const Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}
