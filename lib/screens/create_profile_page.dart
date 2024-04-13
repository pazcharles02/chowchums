import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';

class CreateProfilePage extends StatefulWidget {
  final String userId;

  const CreateProfilePage({super.key, required this.userId});

  @override
  CreateProfilePageState createState() => CreateProfilePageState();
}

class CreateProfilePageState extends State<CreateProfilePage> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  String? selectedFood;
  List<String> foodOptions = [
    "Pizza", "Burger", "Salad", "Sushi", "Pasta", "Taco", "Steak", "Chicken Curry", "Ramen", "Sandwich",
    "Burrito", "Fish and Chips", "Pad Thai", "Lasagna", "Fried Rice", "Pho", "Tacos", "Hot Dog", "BBQ Ribs",
    "Shrimp Scampi", "Chili", "Hamburger", "Mashed Potatoes", "Chicken Wings", "Fajitas", "Cobb Salad", "Gyro",
    "Meatloaf", "Clam Chowder", "Chicken Parmesan", "French Toast", "Fish Tacos", "Caesar Salad",
    "Beef Stroganoff", "Potato Soup", "Crab Cakes", "Stuffed Bell Peppers", "Chicken and Waffles", "Garden Salad",
    "Eggplant Parmesan", "Tuna Salad", "Pad See Ew", "Veggie Burger", "Tom Yum Soup", "Lobster Bisque", "Gnocchi",
    "Spaghetti Carbonara", "Chicken Alfredo", "Beef Tacos", "Pulled Pork Sandwich", "Miso Soup", "Shrimp Fried Rice",
    "Egg Roll", "Chow Mein", "Lamb Gyro", "Carnitas", "Gumbo", "Chicken Salad", "Potato Salad", "Caprese Salad",
    "Philly Cheesesteak", "Mac and Cheese", "Shrimp Cocktail", "Lemon Chicken", "Baked Ziti", "Tomato Soup",
    "Beef and Broccoli", "Cucumber Salad", "Fried Chicken", "Egg Salad", "Garden Burger", "Chicken and Dumplings",
    "Pork Chop", "Cobbler", "Beef Wellington", "Lemon Pepper Chicken", "Stuffed Mushrooms", "Crispy Duck",
    "Crab Rangoon", "Shrimp and Grits", "Chicken Pot Pie", "Ratatouille", "Beef Bourguignon", "Spinach Artichoke Dip",
    "Shepherd's Pie", "Beef Brisket", "Escargot", "Rack of Lamb", "Ginger Beef", "Coq au Vin", "Linguine and Clams",
    "Chicken Enchiladas", "Chicken Cordon Bleu", "Beef Stir Fry", "Lamb Chops", "Buffalo Wings", "Crab Legs",
    "Lobster Roll", "Fish Curry", "Tikka Masala", "Peking Duck", "Cajun Shrimp", "Garlic Shrimp", "Chicken Satay",
    "Vegetable Stir Fry", "Shrimp Etouffee", "Chicken Marsala", "Beef Rendang", "Vegetable Curry", "Tortilla Soup",
    "Beef Empanadas", "Chicken Fajita", "Pork Carnitas", "Szechuan Chicken", "Teriyaki Chicken", "Mongolian Beef",
    "Baked Salmon", "Lemon Butter Shrimp", "Baked Potato", "Garlic Butter Steak", "Roast Beef", "Turkey Sandwich",
    "Grilled Cheese Sandwich", "Cheeseburger", "Spicy Chicken Sandwich", "Fried Fish", "Seafood Paella",
    "Stuffed Cabbage Rolls", "Chicken Tikka", "Beef Kabobs", "Pork Schnitzel", "Butter Chicken",
    "Lemon Herb Roast Chicken", "Crispy Tofu", "Vegetable Lasagna", "Mushroom Risotto", "Eggplant Rollatini",
    "Tiramisu", "Chocolate Cake", "Apple Pie", "Cheesecake", "Creme Brulee", "Panna Cotta", "Tres Leches Cake",
    "Key Lime Pie", "Red Velvet Cake", "Carrot Cake", "Strawberry Shortcake", "Banana Bread", "Blueberry Muffins",
    "Pumpkin Pie", "Cinnamon Rolls", "Chocolate Chip Cookies", "Brownies", "Ice Cream Sundae", "Fruit Salad",
    "Chocolate Fondue", "Caramel Popcorn", "Nachos", "Garlic Bread", "Onion Rings", "Guacamole", "Hummus",
    "Bruschetta", "Deviled Eggs", "Cheese Plate", "Stuffed Jalapenos", "Spinach Dip", "Buffalo Chicken Dip",
    "Salsa and Chips", "Cucumber Sushi Rolls", "Spring Rolls", "Calamari", "Shrimp Tempura", "Crab Dip",
    "Fried Pickles", "Mozzarella Sticks", "Chili Cheese Fries", "Potato Skins", "Buffalo Cauliflower Wings",
    "Bacon Wrapped Dates", "Stuffed Peppers", "Greek Salad", "Ceviche", "Brussels Sprouts", "Kale Salad",
    "Quinoa Salad", "Couscous Salad", "Antipasto Platter", "Meat and Cheese Board", "Fruit Platter", "Crudites",
    "Waldorf Salad", "Nicoise Salad", "Thai Beef Salad", "Watermelon Salad", "Panzanella Salad", "Poke Bowl",
    "Banh Mi Sandwich", "Club Sandwich", "Turkey Wrap", "BLT Sandwich", "Cuban Sandwich", "Monte Cristo Sandwich",
    "Ham and Cheese Croissant", "Bagel with Lox", "Chicken Caesar Wrap", "Vegetable Wrap", "Caprese Panini",
    "Tuna Melt", "Philly Cheesesteak Sandwich", "French Dip Sandwich", "Reuben Sandwich", "Smoked Salmon Bagel",
    "Falafel Wrap"
  ];

  int maxDisplayNameLength = 20;
  int maxBioLength = 150;
  int currentBioLength = 0;
  String? _profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Create your profile!',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      await _uploadProfilePicture(image.path);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: _profileImageUrl == null ||
                                _profileImageUrl!.isEmpty
                            ? const AssetImage(
                                'assets/images/default_picture.png')
                            : NetworkImage(_profileImageUrl!) as ImageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: displayNameController,
                  maxLength: maxDisplayNameLength,
                  onChanged: (text) {
                    if (text.length == maxDisplayNameLength) {
                      _showSnackBar('Maximum display name length reached.');
                    }
                  },
                  decoration: InputDecoration(
                    labelText:
                        'Display Name (Max $maxDisplayNameLength characters)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedFood,
                  onChanged: (newValue) {
                    setState(() {
                      selectedFood = newValue;
                    });
                  },
                  items: foodOptions.map((food) {
                    return DropdownMenuItem<String>(
                      value: food,
                      child: Text(food),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Favorite Food',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: birthdateController,
                  decoration: const InputDecoration(
                    labelText: 'Birthdate (YYYY-MM-DD) Ages:18-125',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  maxLength: maxBioLength,
                  onChanged: (text) {
                    setState(() {
                      currentBioLength = text.length;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Bio (Max $maxBioLength characters)',
                    border: const OutlineInputBorder(),
                    counterText: '$currentBioLength/$maxBioLength',
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  key: const Key('saveProfile'),
                  onPressed: () {
                    saveProfile(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveProfile(BuildContext context) async{
    String displayName = displayNameController.text.trim();
    String bio = bioController.text.trim();
    String city = cityController.text.trim();
    String birthdate = birthdateController.text.trim();

    if (displayName.isEmpty) {
      _showErrorSnackBar('Please enter a display name.');
      return;
    }

    if (displayName.length > maxDisplayNameLength) {
      _showErrorSnackBar(
          'Display name must be less than or equal to $maxDisplayNameLength characters.');
      return;
    }

    if (selectedFood == null || selectedFood!.isEmpty) {
      _showErrorSnackBar('Please select a favorite food.');
      return;
    }

    if (birthdate.isEmpty) {
      _showErrorSnackBar('Please enter a birthdate.');
      return;
    }

    // Validate Birthdate
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(birthdate);
    } catch (e) {
      _showErrorSnackBar(
          'Invalid birthdate format. Please use MM/DD/YYYY format.');
      return;
    }

    if (parsedDate.year < DateTime.now().year - 125 ||
        parsedDate.year > DateTime.now().year - 18) {
      _showErrorSnackBar('Birthdate must be between 18 and 125 years old.');
      return;
    }

    if (city.isEmpty) {
      _showSnackBar('No city entered');
      return;
    }

    if (bio.isEmpty) {
      _showErrorSnackBar('Please enter a bio.');
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference users = firestore.collection('users');

    users.doc(widget.userId).set({
      'displayName': displayName,
      'favoriteFood': selectedFood,
      'biography': bio,
      'profileImageUrl': _profileImageUrl,
      'birthdate': birthdate,
      'city': city,
      'notMatched': [],
      'Matched': [],
    }).then((value) {
      debugPrint("Profile Added");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(userId: widget.userId)),
      );
    }).catchError((error) {
      debugPrint("Failed to add profile: $error");
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _uploadProfilePicture(String? filePath) async {
    if (filePath != null) {
      try {
        final storage = FirebaseStorage.instance;
        final reference =
            storage.ref().child('profile_pictures/${widget.userId}');
        final uploadTask = reference.putFile(File(filePath));
        await uploadTask.whenComplete(() => debugPrint('Image uploaded'));
        final url = await reference.getDownloadURL();
        setState(() {
          _profileImageUrl = url;
          debugPrint("Profile Image URL: $_profileImageUrl");
        });
      } catch (e) {
        debugPrint("Error uploading profile picture: $e");
      }
    }
  }
}
