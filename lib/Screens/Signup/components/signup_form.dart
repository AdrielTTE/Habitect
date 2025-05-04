import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitect/Screens/Login/login_screen.dart'; // Import LoginScreen (if user is redirected here after successful sign-up)
import '../../../constants.dart'; // Import constants if needed
import '../../../components/already_have_an_account_acheck.dart'; // Import this if you're using it for navigation

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = ''; // To store error messages
  bool _isLoading = false; // Loading state during sign-up

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Show success message
        setState(() {
          _isLoading = false;
        });

        // Navigate to login screen after successful sign-up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful! Please log in.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString(); // Show error message if sign-up fails
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
            decoration: const InputDecoration(hintText: 'Your email'),
            validator: (email) {
              if (email == null || email.isEmpty || !email.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Your password'),
            validator: (password) {
              if (password == null || password.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _signUp, // Disable if loading
            child: _isLoading ? const CircularProgressIndicator() : const Text('Sign Up'),
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