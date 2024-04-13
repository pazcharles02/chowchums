import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: const [
            Text('Flutter TCP Demo'),
            Text('created by Julian Aßmann (julianassmann.de)'),
            Text('created with Flutter')
          ],
        ),
      ),
    );
  }
}