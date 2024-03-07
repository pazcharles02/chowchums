import 'package:flutter/material.dart';
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

      // Here, you can save the profile details to a database or perform any necessary actions
      print('Saving profile for user ID: $userId');
      print('Display Name: $displayName');
      print('Favorite Food: $selectedFood');

      // You can navigate to another page after saving the profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'),
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
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
