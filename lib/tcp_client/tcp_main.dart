import 'package:flutter/material.dart';
import 'package:chowchums/tcp_client/tcp_client.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChatPage(userId: "79zlUjIvwhYSnRd5qsF3NTDjNai2"));
}

