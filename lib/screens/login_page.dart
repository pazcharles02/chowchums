import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './registration_page.dart';
import './home_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/chowchums_white_logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
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
              ElevatedButton(
                onPressed: () async {
                  try {
                    String username = usernameController.text;
                    String password = passwordController.text;
                    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: username, password: password);

                    if (userCredential.user != null) {
                      String userId = userCredential.user!.uid;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
                      );
                    } else {
                      // Handle case when user is null
                    }
                  } catch(error) {
                    // Handle login failure
                    print('Login failed: $error');
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text('Create an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
