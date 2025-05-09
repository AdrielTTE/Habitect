import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:habitect/profile.dart';
import 'package:habitect/streakTracking.dart';
import 'package:habitect/home.dart'; // Assuming this is the login screen you want to navigate to
import 'Screens/Welcome/welcome_screen.dart';
import 'TaskScreen.dart';
import 'goal_creation_page.dart'; // Import the welcome screen
import 'goal_creation_page.dart';
import 'home.dart';
import 'calendar_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0; // Track the selected page index
  String? _accountName; // User's name
  String? _accountEmail; // User's email

  // List of titles corresponding to each page
  final List<String> _titles = [
    'Home Page', // Title for Home
    'Goal Creation', // Title for Goal Creation
    'Calender', // Title for Profile
    'Streak Tracking', // Title for Streak Tracking
    'Profile', // Title for Profile
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore using FirebaseAuth UID
  _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Modify the path to match the correct Firestore collection structure
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)  // Use the UID of the logged-in user
            .collection('profile')  // 'profile' subcollection
            .doc('profileData')  // 'profileData' document
            .get();

        if (doc.exists) {
          setState(() {
            _accountName = doc['name'];  // Set the user's name
            _accountEmail = user.email;  // Set the user's email from Firebase Auth (UID email)
          });
        } else {
          print("No profile data found");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Method to update the profile name and email
  Future<void> _updateProfile(String newName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Update Firestore with the new name
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('profileData')
            .set({
          'name': newName,
          'email': _accountEmail, // Ensure email remains tied to the UID email
        }, SetOptions(merge: true));  // Merge to avoid overwriting other data

        // Immediately update the UI
        setState(() {
          _accountName = newName;
        });

        // Optionally show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
  }
  Widget getAppBar() {
    return Scaffold(
      // AppBar with dynamic title and conditional IconButton
      appBar: AppBar(
        title: Text(_titles[_page]), // Dynamically change the title
        backgroundColor: Colors.orangeAccent,
        actions: _page == 0
            ? [
          // Show IconButton only for Home page
          IconButton(
            icon: const Icon(Icons.task),  // Icon for TaskScreen
            onPressed: () {
              // Navigate to TaskScreen when clicked
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TaskScreen(), // TaskScreen should be defined
              ));
            },
          ),
        ]
            : [],
      ),

      // Drawer for navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer header with dynamic name and email
            UserAccountsDrawerHeader(
              accountName: Text(_accountName ?? 'Loading...'), // Display dynamic name
              accountEmail: Text(_accountEmail ?? 'Loading...'), // Display dynamic email
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.orangeAccent),
              ),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
              ),
            ),
            // Drawer menu items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() {
                  _page = 0; // Navigate to Home
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_sharp),
              title: const Text('Goal Creation'),
              onTap: () {
                setState(() {
                  _page = 1; // Navigate to Goal Creation
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar'),
              onTap: () {
                setState(() {
                  _page = 2; // Navigate to Streak Tracking
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Streak Tracking'),
              onTap: () {
                setState(() {
                  _page = 3; // Navigate to Streak Tracking
                });
                Navigator.pop(context); // Close the drawer
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  _page = 4; // Navigate to Profile
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to the login screen after logging out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()), // LoginScreen should be defined
                );
              },
            ),
          ],
        ),
      ),

      // Body content based on selected page
      body: _getSelectedPage(),

      // Curved navigation bar at the bottom
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.orangeAccent,
        color: Colors.orangeAccent,
        animationDuration: const Duration(milliseconds: 280),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.book_sharp, size: 26, color: Colors.white),
          Icon(Icons.calendar_today, size:26, color: Colors.white),
          Icon(Icons.analytics, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
        index: _page, // Sync the bottom navigation bar with the selected page
        onTap: (index) {
          setState(() {
            _page = index; // Update the page index based on the selected icon
          });
        },
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with dynamic title and conditional IconButton
      appBar: AppBar(
        title: Text(_titles[_page]), // Dynamically change the title
        backgroundColor: Colors.orangeAccent,
        actions: _page == 0
            ? [
          // Show IconButton only for Home page
          IconButton(
            icon: const Icon(Icons.task),  // Icon for TaskScreen
            onPressed: () {
              // Navigate to TaskScreen when clicked
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TaskScreen(), // TaskScreen should be defined
              ));
            },
          ),
        ]
            : [],
      ),

      // Drawer for navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer header with dynamic name and email
            UserAccountsDrawerHeader(
              accountName: Text(_accountName ?? 'Loading...'), // Display dynamic name
              accountEmail: Text(_accountEmail ?? 'Loading...'), // Display dynamic email
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.orangeAccent),
              ),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
              ),
            ),
            // Drawer menu items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() {
                  _page = 0; // Navigate to Home
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_sharp),
              title: const Text('Goal Creation'),
              onTap: () {
                setState(() {
                  _page = 1; // Navigate to Goal Creation
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar'),
              onTap: () {
                setState(() {
                  _page = 2; // Navigate to Streak Tracking
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Streak Tracking'),
              onTap: () {
                setState(() {
                  _page = 3; // Navigate to Streak Tracking
                });
                Navigator.pop(context); // Close the drawer
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  _page = 4; // Navigate to Profile
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to the login screen after logging out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()), // LoginScreen should be defined
                );
              },
            ),
          ],
        ),
      ),

      // Body content based on selected page
      body: _getSelectedPage(),

      // Curved navigation bar at the bottom
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.orangeAccent,
        color: Colors.orangeAccent,
        animationDuration: const Duration(milliseconds: 280),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.book_sharp, size: 26, color: Colors.white),
          Icon(Icons.calendar_today, size:26, color: Colors.white),
          Icon(Icons.analytics, size: 26, color: Colors.white),
          Icon(Icons.person, size: 26, color: Colors.white),
        ],
        index: _page, // Sync the bottom navigation bar with the selected page
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
        return Home_Screen(); // Home page content
      case 1:
        return GoalCreationPage(); // Message page content
      case 2:
        return CalendarScreen();
      case 3:
        return StreakTracking(title: '',);// Profile screen placeholder
      case 4:
        return ProfilePage();
      default:
        return Home_Screen(); // Default to home page
    }
  }
}


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),  // Set HomePage as the entry point
  ));
}
