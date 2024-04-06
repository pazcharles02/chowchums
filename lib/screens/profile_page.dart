import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _profileImageUrl = "";

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> _uploadProfilePicture(String filePath) async {
    try {
      final storage = FirebaseStorage.instance;
      final reference = storage.ref().child('profile_pictures/${widget.userId}');
      final uploadTask = reference.putFile(File(filePath));
      await uploadTask.whenComplete(() => print('Image uploaded'));
      final url = await reference.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profileImageUrl': url});
      setState(() {
        _profileImageUrl = url;
        print("Profile Image URL: $_profileImageUrl");
      });
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error fetching data');
        } else {
          final displayName = snapshot.data!.get('displayName');
          final bio = snapshot.data!.get('biography');
          _profileImageUrl = snapshot.data!.get('profileImageUrl') ?? ""; //null checker

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: () async {
                      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        await _uploadProfilePicture(image.path);
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageUrl.isEmpty
                            ? AssetImage('assets/images/default_picture.png')
                            : NetworkImage(_profileImageUrl) as ImageProvider,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        '$displayName',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        '$bio',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.black,
              ),
              child: Text('Logout'),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          );
        }
      },
    );
  }
}
