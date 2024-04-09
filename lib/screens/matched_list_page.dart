import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchedListPage extends StatefulWidget {
  final String userId;

  const MatchedListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MatchedListPageState createState() => _MatchedListPageState();
}

class _MatchedListPageState extends State<MatchedListPage> {
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> _matchedUsersFuture =
      Future.value([]); // Initialize with an empty list

  @override
  void initState() {
    super.initState();
    _fetchMatchedUsers();
  }

  Future<void> _fetchMatchedUsers() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userSnapshot.exists) {
        List<String> matchedArray = List<String>.from(userSnapshot.data()?['Matched'] ?? []);
        setState(() {
          _matchedUsersFuture = _fetchMatchedUserData(matchedArray);
        });
      } else {
        print('User document does not exist');
      }
    } catch (error) {
      setState(() {
        _matchedUsersFuture = Future.error(error.toString()); // Set future with error
      });
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _fetchMatchedUserData(
      List<String> matchedUsers) async {
    List<DocumentSnapshot<Map<String, dynamic>>> matchedUserDocs = [];
    for (String userId in matchedUsers) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      matchedUserDocs.add(userSnapshot);
    }
    return matchedUserDocs;
  }

  void _navigateToUserDetail(String userId) {
    // Navigate to user detail page, passing the userId
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
              child: Text('Error: ${snapshot.error}'), // Display the error message
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No matched users found'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String displayName = snapshot.data![index].get('displayName') ?? 'Unknown';
                String userId = snapshot.data![index].id; // Get user ID
                return GestureDetector(
                  onTap: () => _navigateToUserDetail(userId),
                  child: ListTile(
                    title: Text(displayName),
                    // Add more information about the matched user if needed
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
    // Fetch user details using the provided userId
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: Text('User ID: $userId'), // Display user details here
      ),
    );
  }
}
