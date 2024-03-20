import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

List<Container> cards = [
    Container(
      alignment: Alignment.center,
      child: const Text('1'),
      color: Colors.blue,
    ),
    Container(
      alignment: Alignment.center,
      child: const Text('2'),
      color: Colors.red,
    ),
    Container(
      alignment: Alignment.center,
      child: const Text('3'),
      color: Colors.purple,
    )
  ];

class MatchPage extends StatefulWidget {
  final String userId;
  const MatchPage({Key? key, required this.userId}) : super(key: key);
  

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //LOADING SPINNER wow
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show an error message if there's an error
          return Text('Error fetching data');
        } else {
          //just to check if user is logged in take out later
          final displayName = snapshot.data!.get('displayName');
          return Scaffold(
            body: Flexible(
              child: CardSwiper(
                cardsCount: 3,
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) => cards[index],
              )
            )
          );
        }
      },
    );
  }
}