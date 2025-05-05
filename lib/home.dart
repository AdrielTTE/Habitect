import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:habitect/stream_note.dart';

import 'add_note_screen.dart';
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
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('assets/avatar.jpg'),
          ),
          SizedBox(width: 16),
        ],
      ),

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
                Text("Daily To Do List", style: TextStyle(fontSize: 18)),
                // Stream Notes (for completed tasks, for example)
                Stream_note(false),
                Text(
                  'isDone',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stream_note(true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}