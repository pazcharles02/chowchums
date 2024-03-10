import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './home_page.dart';



class CreateProfilePage extends StatelessWidget {

  
  final String userId;

  const CreateProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController displayNameController = TextEditingController();
    String? selectedFood;
    List<String> foodOptions = ['Pizza', 'Burger', 'Sushi', 'Pasta', 'Salad'];

    void saveProfile() {
      String displayName = displayNameController.text;
      // You can use the selectedFood variable here for the user's choice

      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a reference to the users collection
      CollectionReference users = firestore.collection('users');

      // Create a new document with a unique ID
      users.doc(userId).set({
        'displayName': displayName,
        'favoriteFood': selectedFood,
      })
          .then((value) {
        print("Profile Added");
        // Navigate to another page after saving the profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: userId)),
        );
      })
          .catchError((error) => print("Failed to add profile: $error"));
    }


    return Scaffold(
      appBar: AppBar(

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Create Profile Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedFood,
              onChanged: (newValue) {
                selectedFood = newValue;
              },
              items: foodOptions.map((food) {
                return DropdownMenuItem<String>(
                  value: food,
                  child: Text(food),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Favorite Food',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
              ),
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
