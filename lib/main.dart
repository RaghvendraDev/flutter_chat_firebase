import 'package:chat_firebase_test1/authenticate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: LoginScreen(),
      home: Authenticate(),
    );
  }
}
