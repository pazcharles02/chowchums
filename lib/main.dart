import 'package:flutter/material.dart';
import './screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: myTheme,
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) =>  const LoginPage(), //'/' is route to LoginPage
        '/login': (context) =>  const LoginPage(), //'/login' routing to LoginPage
        // Add other routes as needed
      },
    );
  }
}
