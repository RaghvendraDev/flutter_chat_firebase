import 'package:chat_firebase_test1/crate_login_account.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: TextButton(
        onPressed: () {
          logout(context);
        },
        child: Center(
            child: Text(
          "Logout",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
