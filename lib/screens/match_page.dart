import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MatchPage extends StatefulWidget {
  final String userId;

  const MatchPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final CardSwiperController controller = CardSwiperController();
  late Future<QuerySnapshot<Map<String, dynamic>>> _userFuture;
  List<DocumentSnapshot>? _userData;
  List<String>? matchedArray;
  List<String>? notMatchedArray;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: widget.userId)
        .get();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      if (userSnapshot.exists) {
        matchedArray =
            List<String>.from(userSnapshot.data()?['Matched'] ?? []);
        notMatchedArray =
            List<String>.from(userSnapshot.data()?['notMatched'] ?? []);

        print('Matched Array: $matchedArray');
        print('Not Matched Array: $notMatchedArray');
      } else {
        print('User document does not exist');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    List<DocumentSnapshot>? userData,
    String userID,
  ) {
    if (userData == null ||
        previousIndex < 0 ||
        previousIndex >= userData.length) {
      debugPrint('Invalid userData or out of bounds index');
      return false;
    }

    debugPrint(
        'The card $previousIndex was swiped to the ${direction.name}. Now the card ${currentIndex ?? 'null'} is on top');

    debugPrint('Current User ID: ${userData[previousIndex].id}');

    if (currentIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No more users to match'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }

    if (direction == CardSwiperDirection.left) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({
            'notMatched': FieldValue.arrayUnion([userData[previousIndex].id]),
          })
          .then((_) => debugPrint('User ID added to notMatched field'))
          .catchError((error) =>
              debugPrint('Error adding user ID to notMatched field: $error'));
    }

    if (direction == CardSwiperDirection.right) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({
            'Matched': FieldValue.arrayUnion([userData[previousIndex].id]),
          })
          .then((_) => debugPrint('User ID added to Matched field'))
          .catchError((error) =>
              debugPrint('Error adding user ID to notMatched field: $error'));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error fetching data');
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Text('No user data found');
        } else {
          final userData = snapshot.data!.docs.where((doc) {
            final userId = doc.id;

            return !matchedArray!.contains(userId) &&
                !notMatchedArray!.contains(userId);
          }).toList();

          if (userData.isEmpty) {
            return Container(
              alignment: Alignment.center,
              color: Colors.blue,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No more users to match.'),
                ],
              ),
            );
          }

          List<Widget> fetchedData = userData.map((doc) {
            final name = doc['displayName'];
            final favoriteFood = doc['favoriteFood'];
            final usersID = doc.id;
            final imageURL = doc['profileImageUrl'];
            final bio = doc['biography'];

            return Container(
              color: Colors.blue,
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: imageURL != null
                              ? Image.network(imageURL, fit: BoxFit.cover)
                              : Image.asset('assets/images/default_picture.png',
                                  fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    color: Colors.black,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Favorite Foods: $favoriteFood',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '$bio',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList();

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CardSwiper(
                        controller: controller,
                        cardsCount: fetchedData.length,
                        onSwipe: (previousIndex, currentIndex, direction) =>
                            _onSwipe(previousIndex, currentIndex, direction, userData,
                                widget.userId),
                        isLoop: false,
                        cardBuilder: (context, index, percentThresholdX,
                                percentThresholdY) =>
                            fetchedData[index],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () => controller.swipe(CardSwiperDirection.left),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.keyboard_arrow_left),
                      ),
                      FloatingActionButton(
                        onPressed: () => controller.swipe(CardSwiperDirection.right),
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
