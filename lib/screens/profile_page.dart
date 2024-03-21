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
  String _profileImageUrl = ""; // Store profile image URL chowchums-2c5b3.appspot.com

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page after log out
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
        print("SSSSSSSSSSSSSSSSSSSSS" + _profileImageUrl);
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
          _profileImageUrl = snapshot.data!.get('profileImageUrl');
          // final bio = snapshot.data!.get('biography');
          // print("AAAAAAAAAAAAAAAAAAAAAAAAA" + _profileImageUrl + "AAAAAA" + bio);
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50), // Added space above profile picture
                  // Profile picture section
                  GestureDetector(
                    onTap: () async {
                      // Handle image selection (use a library like image_picker)
                      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        await _uploadProfilePicture(image.path);
                      }
                    },
                    child: Container(
                      width: 100, // Fixed width
                      height: 100, // Fixed height
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageUrl.isEmpty
                            ? AssetImage('assets/images/default_picture.png') // Use AssetImage for local image
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
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Text(
                  //     '$bio',
                  //     style: TextStyle(fontSize: 24),
                  //   ),
                  // ),
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
