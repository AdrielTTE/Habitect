import 'package:flutter/material.dart';
import 'schedule_page.dart';
import 'calendar_page.dart';

void main() {
  runApp(MyScheduleApp());
}

class MyScheduleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;             // Default on Calendar

  final List<Widget> _pages = [
    SchedulePage(),
    CalendarScreen(),
    Placeholder(), // For Streak (you can create separate page later)
    Placeholder(), // For Account
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade100,
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.orange : Colors.grey),
                  onPressed: () => _onItemTapped(0)),
              IconButton(
                  icon: Icon(Icons.calendar_today, color: _selectedIndex == 1 ? Colors.orange : Colors.grey),
                  onPressed: () => _onItemTapped(1)),
              SizedBox(width: 40), // space for FAB
              IconButton(
                  icon: Icon(Icons.show_chart, color: _selectedIndex == 2 ? Colors.orange : Colors.grey),
                  onPressed: () => _onItemTapped(2)),
              IconButton(
                  icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.orange : Colors.grey),
                  onPressed: () => _onItemTapped(3)),
            ],
          ),
        ),
      ),
    );
  }
}
