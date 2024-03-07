// main.dart

import 'package:flutter/material.dart';
import './screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  await Firebase.initializeApp();
  runApp(const MyApp());


  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Initially show the login page
    );
  }
}
