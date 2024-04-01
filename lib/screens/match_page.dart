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
  ) {
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );

    if(currentIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No more users to match'),
        behavior: SnackBarBehavior.fixed,
        duration: Duration(days: 1),
      ),
    );
    

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
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              onSwipe: _onSwipe,
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
