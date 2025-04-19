import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login/models/history_page.dart';

class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final user = FirebaseAuth.instance.currentUser;
  int coin = 0;
  int tree = 0;
  bool isLoading = true;

  final List<int> values = [10, 20, 30, 40, 100];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        coin = data['coin'] ?? 0;
        tree = data['tree'] ?? 0;
        isLoading = false;
      });
    }
  }

  void showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> tradeTreeToCoin(int treeAmount) async {
    int getCoin = (treeAmount == 100) ? 50 : (treeAmount ~/ 10) * 2;

    if (tree < treeAmount) {
      showNotification("คุณมี Tree ไม่พอ");
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'tree': tree - treeAmount,
      'coin': coin + getCoin,
    });

    await FirebaseFirestore.instance.collection('transactions').add({
      'uid': user!.uid,
      'type': 'tree_to_coin',
      'amount': getCoin,
      'tree_used': treeAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      tree -= treeAmount;
      coin += getCoin;
    });

    showNotification("แลก $treeAmount Tree ได้ $getCoin Coin แล้ว!");
  }

  Future<void> tradeCoinToMoney(int coinAmount) async {
    if (coin < coinAmount) {
      showNotification("คุณมี Coin ไม่พอ");
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final snapshot = await docRef.get();
    final data = snapshot.data();
    int currentMoney = data?['money'] ?? 0;

    await docRef.update({
      'coin': coin - coinAmount,
      'money': currentMoney + coinAmount,
    });

    await FirebaseFirestore.instance.collection('transactions').add({
      'uid': user!.uid,
      'type': 'coin_to_money',
      'amount': coinAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      coin -= coinAmount;
    });

    showNotification("แลก $coinAmount Coin เป็น $coinAmount เงินแล้ว!");
  }

  void goToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8D5A2),
      appBar: AppBar(
        title: const Text("Trade Money"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: goToHistoryPage,
          )
        ],
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.forest, color: Colors.green[700]),
                              const SizedBox(width: 6),
                              Text("Tree: $tree", style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.orange[700]),
                              const SizedBox(width: 6),
                              Text("Coin: $coin", style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text("🌱 ➜ 💰", style: TextStyle(fontSize: 20)),
                          VerticalDivider(thickness: 1, color: Colors.grey),
                          Text("💰 ➜ 💵", style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          final val = values[index];
                          final treeToCoin = (val == 100) ? 50 : (val ~/ 10) * 2;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => tradeTreeToCoin(val),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.shade300),
                                      ),
                                      child: Center(
                                        child: Text("$val = $treeToCoin", style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => tradeCoinToMoney(val),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color:  Colors.green.shade300),
                                      ),
                                      child: Center(
                                        child: Text("$val = $val", style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}