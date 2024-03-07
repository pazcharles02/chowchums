// registration_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<void> registerUser(BuildContext context) async {
    try {
      String username = usernameController.text;
      String password = passwordController.text;
      String confirmedPassword = confirmPasswordController.text;



      if(password == confirmedPassword) {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: username,
          password: password,
        );

      }


    } catch (err) {
      print('Failed to register user: $err');

    }
  }
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Registration Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: true,
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser(context);
               
              },
              child: Text('Register'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
