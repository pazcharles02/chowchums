import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchedListPage extends StatefulWidget {
  final String userId;

  const MatchedListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MatchedListPageState createState() => _MatchedListPageState();
}

class _MatchedListPageState extends State<MatchedListPage> {
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> _matchedUsersFuture;

  @override
  void initState() {
    super.initState();
    _matchedUsersFuture = _fetchMatchedUsers(); // Assign the future result to _matchedUsersFuture
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _fetchMatchedUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (usersSnapshot.docs.isNotEmpty) {
        List<DocumentSnapshot<Map<String, dynamic>>> matchedUserDocs = [];

        for (DocumentSnapshot<Map<String, dynamic>> userSnapshot
            in usersSnapshot.docs) {
          if (userSnapshot.data()?['Matched']?.contains(widget.userId) ?? false) {
            matchedUserDocs.add(userSnapshot);
          }
        }

        return matchedUserDocs;
      } else {
        print('No users found');
        return []; // Return an empty list if no users are found
      }
    } catch (error) {
      print('Error fetching matched users: $error');
      throw error; // Throw the error to propagate it
    }
  }

  void _navigateToUserDetail(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Users'),
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: _matchedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No matched users found'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String displayName =
                    snapshot.data![index].get('displayName') ?? 'Unknown';
                String userId = snapshot.data![index].id;
                return GestureDetector(
                  onTap: () => _navigateToUserDetail(userId),
                  child: ListTile(
                    title: Text(displayName),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Text('User ID: $userId'),
      ),
    );
  }
}
