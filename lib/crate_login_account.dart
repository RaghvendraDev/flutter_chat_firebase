import 'dart:io';

import 'package:chat_firebase_test1/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<User?> createAccount(
    String name, String email, String pass, File _imageFile) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  //to save user details in firestore
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: pass))
        .user;
//creating image to url
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(user!.uid + ".jpg");

    await ref.putFile(_imageFile).whenComplete(() {});
    final url = await ref.getDownloadURL();

    if (user != null) {
      print("Account creation  Succesful");

      //update display name

      user.updateDisplayName(name);
//saing userdata in firestore also(for chat feature)

      _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "unvailable",
        "profilepic": url,
        "uid": _auth.currentUser!.uid,
      });
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
