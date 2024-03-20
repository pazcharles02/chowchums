import 'package:flutter/material.dart';
import './registration_page.dart';
import './home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0), // Adjust top padding
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
                key: Key('login_button'), 
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
                      print('User is null');
                    }

                  } catch(error) {
                    print('login failed');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage(auth: _auth)),
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
