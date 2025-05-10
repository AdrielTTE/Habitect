import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitect/Screens/Welcome/welcome_screen.dart';

import '../../../HomePage.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = ''; // For error message display

  // Login method
  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to sign in with Firebase
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Navigate to Home Page after successful login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Color(0x4DFFB84D)),
            validator: (email) {
              if (email == null || email.isEmpty || !email.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height:20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password',
                filled: true,
                fillColor: Color(0x4DFFB84D)),
            validator: (password) {
              if (password == null || password.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height:40),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.orangeAccent),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}