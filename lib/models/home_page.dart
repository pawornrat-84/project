import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<DateTime, bool> wateringDates = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWateringDates().then((dates) {
      setState(() {
        wateringDates = dates;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8D5A2),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return const Text("Hi! User");
                          }

                          final rawData = snapshot.data!.data();
                          if (rawData == null || rawData is! Map<String, dynamic>) {
                            return const Text("Hi! User");
                          }

                          final name = rawData['name'] ?? 'User';

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Hi! $name",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Icon(Icons.person, size: 28, color: Colors.green),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forest, size: 80, color: Colors.green),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Day", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              Text("${wateringDates.length}", style: const TextStyle(fontSize: 48, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: DateTime.now(),
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, _) {
                                if (isWatered(date)) {
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            headerVisible: false,
                            daysOfWeekVisible: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: markTodayWatered,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text("บันทึกว่ารดน้ำวันนี้แล้ว", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<Map<DateTime, bool>> fetchWateringDates() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final data = doc.data();
    if (data == null) return {};

    final dateMap = <DateTime, bool>{};

    if (data['treeWateringDates'] != null) {
      (data['treeWateringDates'] as Map<String, dynamic>).forEach((key, value) {
        final parsedDate = DateTime.tryParse(key);
        if (parsedDate != null && value == true) {
          dateMap[parsedDate] = true;
        }
      });
    }

    return dateMap;
  }

  bool isWatered(DateTime day) {
    return wateringDates.keys.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  Future<void> markTodayWatered() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final formatted = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    if (wateringDates.containsKey(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("คุณรดน้ำวันนี้ไปแล้ว")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'treeWateringDates': {formatted: true}
    }, SetOptions(merge: true));

    setState(() {
      wateringDates[todayOnly] = true;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("บันทึกการรดน้ำต้นไม้แล้ว!")));
  }
}
