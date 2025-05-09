import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:habitect/profile.dart';
import 'package:habitect/streakTracking.dart';
import 'package:habitect/streakTracking.dart';
import 'package:habitect/stream_note.dart';
import 'add_note_screen.dart';
import 'calendar_page.dart';
import 'goal_creation_page.dart'; // Import the Goal Page
import 'constants.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

bool show = true;

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      floatingActionButton: Visibility(
        visible: show,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Add_creen(),
            ));
          },
          backgroundColor: custom_green,
          child: Icon(Icons.add, size: 30),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              setState(() {
                show = true;
              });
            }
            if (notification.direction == ScrollDirection.reverse) {
              setState(() {
                show = false;
              });
            }
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Motivational Quote Image
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(26),
                  child: const Image(
                    image: AssetImage('assets/images/mask.png'),
                    width: 350,
                  ),
                ),
                // Daily To Do List Text

                // 4 Box with Icons (Book, Calendar, User, Time)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Book Icon - Goal Page
                      _buildBox(Icons.book, "Goal", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GoalCreationPage()),
                        );
                      }),
                      // Calendar Icon - Calendar Page
                      _buildBox(Icons.calendar_today, "Calendar", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CalendarScreen()),
                        );
                      }),
                      // User Icon - Summary Page
                      _buildBox(Icons.analytics, "Summary", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StreakTracking(title: '',)),
                        );
                      }),
                      // Time Icon - User Page
                      _buildBox(Icons.person, "User", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      }),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Daily To Do List",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Stream Notes (for completed tasks)
                Stream_note(false),
                Text(
                  'isDone',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Stream Notes (for tasks to be done)
                Stream_note(true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create each icon box
  Widget _buildBox(IconData icon, String label, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.grey),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
