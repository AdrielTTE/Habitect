import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'goal_creation_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD6h5CEDKNqF8FlqrUgxnQkzqx5HRpY9B0",
      appId: "1:95706388458:web:48d8ac3227d333c10e0493",
      messagingSenderId: "95706388458",
      projectId: "habitect-74f40",
      storageBucket: "habitect-74f40.firebasestorage.app",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoalCreationPage(),
    );
  }
}
