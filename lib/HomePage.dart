import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'Habit.dart';
import 'goal_creation_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0; // Track the selected page index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body content based on selected page
      body: _getSelectedPage(),

      // Curved navigation bar at the bottom
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.orangeAccent,
        color: Colors.orangeAccent,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _page = index; // Update the page index based on the selected icon
          });
        },
      ),
    );
  }

  // Method to return different content based on selected page
  Widget _getSelectedPage() {
    switch (_page) {
      case 0:
        return Habit(); // Home page content
      case 1:
        return GoalCreationPage(); // Message page content
      case 2:
        return Center(child: Text('Add Screen')); // Add screen placeholder
      case 3:
        return Center(child: Text('Notifications Screen')); // Notifications screen placeholder
      case 4:
        return Center(child: Text('Profile Screen')); // Profile screen placeholder
      default:
        return Habit(); // Default to home page
    }
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),  // Set HomePage as the entry point
  ));
}