import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("กรุณาเข้าสู่ระบบ"));
    }

    final transactionsRef = FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติการแลกเปลี่ยน"),
        backgroundColor: const Color(0xFFAED6AE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactionsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาด"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีประวัติการแลก"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final type = data['type'];
              final amount = data['amount'];
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final time = timestamp != null
                  ? DateFormat('d MMM yyyy • HH:mm').format(timestamp)
                  : 'ไม่ทราบเวลา';

              String title = '';
              Icon icon;

              if (type == 'tree_to_coin') {
                final treeUsed = data['tree_used'] ?? '?';
                title = 'แลก $treeUsed ต้นไม้ เป็น $amount Coin';
                icon = const Icon(Icons.forest, color: Colors.green);
              } else if (type == 'coin_to_money') {
                title = 'แลก $amount Coin เป็น เงิน';
                icon = const Icon(Icons.attach_money, color: Colors.orange);
              } else {
                title = 'ไม่ทราบประเภท';
                icon = const Icon(Icons.error_outline);
              }

              return ListTile(
                leading: icon,
                title: Text(title),
                subtitle: Text(time),
              );
            },
          );
        },
      ),
    );
  }
}
