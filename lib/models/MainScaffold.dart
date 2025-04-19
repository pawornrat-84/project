import 'package:flutter/material.dart';
import 'package:login/models/forest_page.dart';
import 'package:login/models/history_page.dart';
import 'package:login/models/home_page.dart';
import 'package:login/models/setting_page.dart';
import 'package:login/models/trade_page.dart';
import 'package:login/models/MainScaffold.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainScaffold(), debugShowCheckedModeBanner: false);
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 2;

  final List<IconData> _icons = [
    Icons.forest,
    Icons.history,
    Icons.home,
    Icons.paid,
    Icons.settings,
  ];
final List<Widget> _pages = [
  CoinTreePage(),
  HistoryPage(),
  HomePage(),
  TradePage(),
  SettingPage(),
];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFAED4A3),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (index) {
              return IconButton(
                icon: Icon(
                  _icons[index],
                  size: _icons[index] == Icons.home ? 30 : 24,
                  color: _selectedIndex == index ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
