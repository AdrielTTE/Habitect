import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Habitect Calendar',
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: CalendarScreen(),
        debugShowCheckedModeBanner: false,
        );
    }
}