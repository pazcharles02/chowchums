import 'package:flutter/material.dart';
import './create_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chowchums/tcp_client/tcp_client.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while fetching data
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if there's an error
          return Text('Error fetching data');
        } else {
          // Data is successfully fetched
          final displayName = snapshot.data!.get('displayName');
          return Scaffold(
            appBar: AppBar(
              title: Text('Home'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome $displayName!',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateProfilePage(userId: widget.userId),
                        ),
                      );
                    },
                    child: Text('Edit profile'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      runApp(App());
                    },
                    style: ElevatedButton.styleFrom(
                    ),
                    child: Text('Chat Here!'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
