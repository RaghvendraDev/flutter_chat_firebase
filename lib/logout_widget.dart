import 'package:chat_firebase_test1/crate_login_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LogoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          //setting online/offline status to current user
          try {
            await _firestore
                .collection("users")
                .doc(_auth.currentUser!.uid)
                .update({
              "status": "Offline",
            }).then((value) {
              logout(context);
            });
          } catch (e) {
            // print("status cant be change");
          }
        },
        icon: Icon(Icons.logout));
  }
}
