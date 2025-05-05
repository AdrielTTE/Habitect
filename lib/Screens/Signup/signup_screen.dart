import 'package:flutter/material.dart';
import 'package:habitect/constants.dart';
import 'package:habitect/responsive.dart';
import '../../components/background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Main content of the screen
          const Background(
            child: SingleChildScrollView(
              child: Responsive(
                mobile: MobileSignupScreen(),
                desktop: Row(
                  children: [
                    Expanded(child: SignUpScreenTopImage()),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 450, child: SignUpForm()),
                          SizedBox(height: defaultPadding / 2),
                          // SocalSignUp()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //Back Arrow
          Positioned(
            top: 40.0,
            left: 16.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        SignUpScreenTopImage(),
    Row(
    children: [
    Spacer(),
    Expanded(flex: 8, child: SignUpForm()),
    Spacer(),
    ],
    ),
    // const SocalSignUp()
    ],
    );
    }
}