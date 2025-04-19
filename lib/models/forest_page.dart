import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CoinTreePage extends StatefulWidget {
  const CoinTreePage({super.key});

  @override
  State<CoinTreePage> createState() => _CoinTreePageState();
}

class _CoinTreePageState extends State<CoinTreePage> {
  final user = FirebaseAuth.instance.currentUser;
  int coin = 0;
  int tree = 0;
  bool isLoading = true;
  bool showWarning = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      final Timestamp? lastUpdate = data['lastTreeUpdate'];
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime? lastDate = lastUpdate?.toDate();

      setState(() {
        coin = data['coin'] ?? 0;
        tree = data['tree'] ?? 0;
        showWarning =
            lastDate == null ||
            lastDate.year != today.year ||
            lastDate.month != today.month ||
            lastDate.day != today.day;
        isLoading = false;
      });
    }
  }

  Future<void> updateValue(String field, int change) async {
  if (user == null) return;

  final newValue = (field == 'coin' ? coin : tree) + change;
  if (newValue < 0) return;

  final updateData = <String, dynamic>{};  

  updateData[field] = newValue;

  if (field == 'tree' && change > 0) {
    updateData['lastTreeUpdate'] = FieldValue.serverTimestamp(); 
  }


  await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(updateData);


  fetchUserData();

  setState(() {
    if (field == 'coin') {
      coin = newValue;
    } else {
      tree = newValue;
      if (change > 0) showWarning = false;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED6AE),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$coin Coin",
                          style: const TextStyle(fontSize: 20),
                        ),
                        const VerticalDivider(),
                        Text(
                          "$tree Tree",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (showWarning)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    
                    ),
                  const SizedBox(height: 20),
                  
                  const Icon(Icons.forest, size: 300, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 30),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Icon(Icons.forest, size: 40),
                            Icon(Icons.drag_handle, size: 30),
                            Icon(Icons.paid, size: 40),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => updateValue('tree', -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => updateValue('tree', 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
