import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './create_profile_page.dart';
import 'dart:math';

class RandomUser {
  final String email;
  final String password;

  RandomUser(this.email, this.password);
}

Future<void> registerRandomUsers(BuildContext context, int count) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;

    for (int i = 0; i < count; i++) {
      String email = 'user${Random().nextInt(1000)}@example.com'; // Generating random email
      String password = 'password${Random().nextInt(1000)}'; // Generating random password

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // User registration successful
        debugPrint('User registered successfully: ${userCredential.user!.email}');
        // Optionally, you can navigate to another page or perform other actions here
      }
    }
  } catch (error) {
    // Handle registration errors
    debugPrint('Failed to register user: $error');
    if(context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register user: $error'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class RegistrationPage extends StatelessWidget {
  final FirebaseAuth auth;

  const RegistrationPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    Future<void> registerUser(BuildContext context) async {
      try {
        String email = usernameController.text;
        String password = passwordController.text;
        String confirmedPassword = confirmPasswordController.text;

        if (password.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password must be at least 6 characters long.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (password == confirmedPassword) {
          UserCredential userCredential = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.user != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateProfilePage(userId: userCredential.user!.uid)),
            );
          }
        } else {
          if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Passwords do not match. Please make sure the passwords match.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (err) {
        debugPrint('Failed to register user: $err');
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to register user: email already in use'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'assets/images/chowchums_white_logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('emailTextField'),
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('passwordTextField'),
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10), // Adjusted height
              TextField(
                key: const Key('confirmPasswordTextField'),
                obscureText: true,
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  registerUser(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
