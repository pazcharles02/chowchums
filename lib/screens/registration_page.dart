import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home_page.dart';
import './create_profile_page.dart';

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
        String email = usernameController.text;
        String password = passwordController.text;
        String confirmedPassword = confirmPasswordController.text;

        if (password == confirmedPassword) {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // If registration is successful, navigate to CreateProfilePage
          if (userCredential.user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateProfilePage(userId: userCredential.user!.uid)),
            );
          }
        } else {
          // Handle passwords not matching
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Passwords do not match'),
                content: Text('Please make sure the passwords match.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (err) {
        print('Failed to register user: $err');
        // Handle other registration errors if needed
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
                labelText: 'Email',
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
