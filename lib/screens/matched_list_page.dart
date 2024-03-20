import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  String name;
  // Other profile data like image, bio, etc.

  UserProfile({required this.id, required this.name});
}

class MatchedUsersPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserId; // ID of the current user

  MatchedUsersPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matched Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('likes').where('likedUserId', isEqualTo: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final likedUsers = snapshot.data!.docs.map((doc) => doc['likingUserId']).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('likes').where('likingUserId', isEqualTo: currentUserId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final likedByUsers = snapshot.data!.docs.map((doc) => doc['likedUserId']).toList();

              final matchedUsers = likedUsers.where((user) => likedByUsers.contains(user)).toList();

              return matchedUsers.isEmpty
                  ? Center(
                      child: Text('No matched users yet!'),
                    )
                  : ListView.builder(
                      itemCount: matchedUsers.length,
                      itemBuilder: (context, index) {
                        // Fetch matched user profile from Firestore or wherever you store profiles
                        UserProfile matchedUser = UserProfile(id: matchedUsers[index], name: "Matched User $index");

                        return ListTile(
                          title: Text(matchedUser.name),
                          // You can display more profile information here
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }
}
