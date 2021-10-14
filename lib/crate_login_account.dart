import 'dart:io';

import 'package:chat_firebase_test1/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<User?> createAccount(
    String name, String email, String pass, File _imageFile) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: pass))
        .user;

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(user!.uid + ".jpg");

    await ref.putFile(_imageFile).whenComplete(() {});
    final url = await ref.getDownloadURL();

    if (user != null) {
      print("Account creation  Succesful");
      return user;
    } else {
      print("Account creation Failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> login(String email, String pass) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user =
        (await _auth.signInWithEmailAndPassword(email: email, password: pass))
            .user;

    if (user != null) {
      print("Login Succesful");
      return user;
    } else {
      print("Login Failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future logout(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signOut().then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  } catch (e) {
    print("error");
  }
}
