/*
User Story #1
As a new user, I want to easily create a profile by providing basic information so that I can start connecting with potential new friends .

*Acceptance Criteria: User can give their name and favourite foods.

*/
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:chowchums/screens/create_profile_page.dart';

// Mock FirebaseAuth instance using Mockito
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {

  testWidgets('Test create profile page', (WidgetTester tester) async {
    // Build the CreateProfilePage widget
    await tester.pumpWidget(const MaterialApp(
      home: CreateProfilePage(userId: 'rgyHvjwoKzW7fm6WHtkMZqPcZ9W2'), // Provide a userId for testing
    ));

    // Verify if 'Create Profile Page' text is present
    expect(find.text('Create your profile!'), findsOneWidget);


    

  });
}
