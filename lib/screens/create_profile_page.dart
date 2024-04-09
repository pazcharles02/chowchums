import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';

class CreateProfilePage extends StatefulWidget {
  final String userId;

  const CreateProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  String? selectedFood;
  List<String> foodOptions = [
    'Pizza', 'Burger', 'Sushi', 'Pasta', 'Salad', 'Tacos', 'Steak', 'Ramen', 'Curry', 'Fried Chicken',
    'Sandwiches', 'Barbecue', 'Seafood', 'Dim Sum', 'Pho', 'Tapas', 'Crepes', 'Noodles', 'Gyros',
    'Shawarma', 'Poutine', 'Burritos', 'Enchiladas', 'Paella', 'Biryani', 'Goulash', 'Lasagna',
    'Hot Pot', 'Kebab', 'Meatloaf', 'Ribs', 'Roast Beef', 'Spring Rolls', 'Samosa', 'Empanadas',
    'Sushi Burrito', 'Jambalaya', 'Calzone', 'Ceviche', 'Fish and Chips', 'Gumbo', 'Moussaka',
    'Pierogi', 'Peking Duck', 'Reuben Sandwich', 'Vindaloo', 'Wontons', 'Dumplings', 'Cannoli',
    'Baklava', 'Biscuits and Gravy', 'Crab Cakes', 'Croissant', 'Eggplant Parmesan', 'Falafel',
    'Hummus', 'Macarons', 'Pad Thai', 'Pancakes', 'Peking Duck', 'Pierogi', 'Pot Stickers',
    'Pulled Pork', 'Ratatouille', 'Sashimi', 'Schnitzel', 'Souvlaki', 'Stuffed Peppers',
    'Tempura', 'Teriyaki Chicken', 'Tiramisu', 'Truffles', 'Waffles', 'Ziti', 'Banana Bread',
    'Butter Chicken', 'Cobb Salad', 'Coq au Vin', 'Couscous', 'Egg Rolls', 'Gazpacho', 'Guacamole',
    'Lamb Tagine', 'Lobster Bisque', 'Monkey Bread', 'Nachos', 'Pastrami Sandwich', 'Potato Skins',
    'Quiche', 'Risotto', 'Salmon Teriyaki', 'Scampi', 'Spanakopita', 'Tater Tots', 'Tom Yum Soup',
    'Tostadas', 'Vegetable Tempura', 'Yakitori', 'Zuppa Toscana', 'Arancini', 'Beef Wellington',
    'Blackened Fish', 'Buffalo Wings', 'Chimichanga', 'Clam Chowder', 'Croque Monsieur', 'Dosa',
    'Fettuccine Alfredo', 'French Dip Sandwich', 'Garlic Bread', 'General Tso Chicken', 'Gnocchi',
    'Hush Puppies', 'Kimchi', 'Linguine Carbonara', 'Mango Sticky Rice', 'Margarita Pizza',
    'Mole', 'New England Clam Bake', 'Oysters Rockefeller', 'Panang Curry', 'Peach Cobbler',
    'Peking Pork', 'Penne Vodka', 'Po\' Boy Sandwich', 'Portuguese Chicken', 'Pozole', 'Pumpkin Pie',
    'Red Beans and Rice', 'Scotch Egg', 'Seafood Boil', 'Shepherd\'s Pie', 'Shrimp and Grits',
    'Stromboli', 'Surf and Turf', 'Tikka Masala', 'Tuna Tartare', 'Walnut Cake', 'Whiskey Cake',
    'Zabaglione', 'Ziti al Forno', 'Alfredo Sauce', 'Barbacoa', 'Borscht', 'Carnitas', 'Chow Mein',
    'Colcannon', 'Drunken Noodles', 'Frittata', 'Huevos Rancheros', 'Katsu Curry', 'Lobster Roll',
    'Meat Pie', 'Mulligatawny Soup', 'Okonomiyaki', 'Osso Buco', 'Paprikash', 'Peach Melba',
    'Philly Cheesesteak', 'Pineapple Upside-Down Cake', 'Piroshki', 'Pot Pie', 'Ravioli',
    'Saltimbocca', 'Sauerbraten', 'Shakshuka', 'She-crab Soup', 'Sopa de Lima', 'Sorbet',
    'Spaghetti Carbonara', 'Steak Diane', 'Tarte Tatin', 'Thai Red Curry', 'Tres Leches Cake',
    'Veal Parmesan', 'Waldorf Salad', 'Welsh Rarebit', 'Yellow Curry', 'Zucchini Bread',
    'Apple Strudel', 'Beef Stroganoff', 'Blueberry Pie', 'Boeuf Bourguignon', 'Bruschetta',
    'Chicken and Waffles', 'Chili Con Carne', 'Churros', 'Clafoutis', 'Cobbler', 'Coq au Vin',
    'Crème Brûlée', 'Daiquiri', 'Fajitas', 'French Toast', 'Fried Rice', 'Fruitcake', 'Gingerbread',
    'Goulash', 'Gumbo', 'Hot Dog', 'Ice Cream', 'Jerk Chicken', 'Key Lime Pie', 'Lemon Meringue Pie',
    'Linguine', 'Lobster Mac and Cheese', 'Mango Lassi', 'Margherita Pizza', 'Martini', 'Mimosa',
    'Miso Soup', 'Mojito', 'Moussaka', 'Mulligatawny Soup', 'Nachos', 'Pad See Ew', 'Pad Thai',
    'Pancakes', 'Panna Cotta', 'Peach Cobbler', 'Peach Pie', 'Pesto', 'Pierogi', 'Pineapple Fried Rice',
    'Pot Roast', 'Prime Rib', 'Pulled Pork Sandwich', 'Quesadillas', 'Quiche', 'Ratatouille', 'Ravioli',
    'Risotto', 'Roast Chicken', 'Roast Pork', 'Samosas', 'Sangria', 'Sashimi', 'Scallops', 'Scone',
    'Scotch Egg', 'Shrimp and Grits', 'Shrimp Cocktail', 'Smoked Salmon', 'Smoothie', 'Sorbet',
    'Sorbet', 'Spaghetti and Meatballs', 'Spanakopita', 'Spring Rolls', 'Squash Soup', 'Steak Frites',
    'Steak Tartare', 'Stuffed Mushrooms', 'Stuffed Peppers', 'Sushi', 'Tandoori Chicken',
    'Tapioca Pudding', 'Tempura', 'Teriyaki Chicken', 'Tiramisu', 'Tom Kha Gai', 'Tom Yum Goong',
    'Tortilla Soup', 'Tuna Casserole', 'Tuna Salad', 'Veggie Burger', 'Vindaloo', 'Waffles',
    'Watermelon Salad', 'Ziti', 'Zoodles'
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
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                        image: _profileImageUrl == null || _profileImageUrl!.isEmpty
                            ? const AssetImage('assets/images/default_picture.png')
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
                    labelText: 'Display Name (Max $maxDisplayNameLength characters)',
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
                  onPressed: () {
                    saveProfile();
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

  void saveProfile() {
    String displayName = displayNameController.text.trim();
    String bio = bioController.text.trim();
    String city = cityController.text.trim();
    String birthdate = birthdateController.text.trim();

    if (displayName.isEmpty) {
      _showErrorSnackBar('Please enter a display name.');
      return;
    }

    if (displayName.length > maxDisplayNameLength) {
      _showErrorSnackBar('Display name must be less than or equal to $maxDisplayNameLength characters.');
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
      _showErrorSnackBar('Invalid birthdate format. Please use MM/DD/YYYY format.');
      return;
    }

    if (parsedDate.year < DateTime.now().year - 125 || parsedDate.year > DateTime.now().year - 18) {
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

    users
        .doc(widget.userId)
        .set({
      'displayName': displayName,
      'favoriteFood': selectedFood,
      'biography': bio,
      'profileImageUrl': _profileImageUrl,
      'birthdate': birthdate,
      'city': city,
      'notMatched': [],
      'Matched': [],
    })
        .then((value) {
      print("Profile Added");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
      );
    })
        .catchError((error) => print("Failed to add profile: $error"));
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
        final reference = storage.ref().child('profile_pictures/${widget.userId}');
        final uploadTask = reference.putFile(File(filePath));
        await uploadTask.whenComplete(() => print('Image uploaded'));
        final url = await reference.getDownloadURL();
        setState(() {
          _profileImageUrl = url;
          print("Profile Image URL: $_profileImageUrl");
        });
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
    }
  }
}
