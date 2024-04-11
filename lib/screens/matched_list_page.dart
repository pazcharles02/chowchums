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
void _navigateToUserDetail(String userId, String otherUserId) {
  // Navigate to user detail page, passing both userId and otherUserId
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserDetailsPage(userId: userId, otherUserId: otherUserId),
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
                  onTap: () => _navigateToUserDetail(userId, widget.userId),
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

class UserDetailsPage extends StatefulWidget {
  final String userId;
  final String otherUserId;

  const UserDetailsPage({Key? key, required this.userId, required this.otherUserId}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_getChatId(widget.userId, widget.otherUserId))
          .collection('messages')
          .add({
        'message': message,
        'senderId': widget.userId,
        'timestamp': Timestamp.now(),
      });

      // Clear the text field after sending the message
      _messageController.clear();
    }
  }

  String _getChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_getChatId(widget.userId, widget.otherUserId))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // To display the latest message at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    String message = messages[index]['message'];
                    String senderId = messages[index]['senderId'];

                    return ListTile(
                      title: Text(message),
                      subtitle: Text(senderId),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
