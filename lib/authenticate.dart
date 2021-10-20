import 'package:chat_firebase_test1/first_screen.dart';
import 'package:chat_firebase_test1/home_screen.dart';
import 'package:chat_firebase_test1/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Authenticate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      // return HomeScreen();
      return FirstScreen();
    } else {
      return LoginScreen();
    }
  }
}
