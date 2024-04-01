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

 
    @override
  void initState() {
    super.initState();
    controller.dispose();
    _userFuture = FirebaseFirestore.instance.collection('users').get();
  }


  bool _onSwipe(
  int previousIndex,
  int? currentIndex,
  CardSwiperDirection direction,
  List<DocumentSnapshot>? userData,
  String userID,
) {
  if (userData == null || previousIndex < 0 || previousIndex >= userData.length) {
    debugPrint('Invalid userData or out of bounds index');
    return false;
  }

  debugPrint(
    'The card $previousIndex was swiped to the ${direction.name}. Now the card ${currentIndex ?? 'null'} is on top',
  );

debugPrint('Current User ID: ${userData[previousIndex].id}');

  if (currentIndex == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No more users to match'),
        behavior: SnackBarBehavior.fixed,
      ),
    ); 
  }

  if (direction == CardSwiperDirection.left) {
    // Add the user ID to the 'notMatched' field in Firestore
    FirebaseFirestore.instance.collection('users').doc(userID).update({
      'notMatched': FieldValue.arrayUnion([userData[previousIndex].id]),
    }).then((_) {
      debugPrint('User ID added to notMatched field');
    }).catchError((error) {
      debugPrint('Error adding user ID to notMatched field: $error');
    });
  }

  return true;
}


  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error fetching data');
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('No user data found');
        } else {
          final userData = snapshot.data!.docs;
          List<Widget> fetchedData = userData.map((doc) {
            final name = doc['displayName'];
            final favoriteFood = doc['favoriteFood'];
            final usersID = doc.id;
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('User ID: $usersID'),
                  Text('User Display Name: $name'),
                  Text('favorite Foods: $favoriteFood'),
                ],
              ),
              color: Colors.blue,
            );
          }).toList();
          return Scaffold(
            body: CardSwiper(
              controller: controller,
              cardsCount: fetchedData.length,
              onSwipe: (previousIndex, currentIndex, direction) =>
                _onSwipe(previousIndex, currentIndex, direction, userData, widget.userId),
              isLoop: false,
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
                  fetchedData[index],
            ),
            
          );
        }
      },
    );
  }
}
