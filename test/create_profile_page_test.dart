import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:chowchums/screens/create_profile_page.dart';

// Mock FirebaseAuth instance using Mockito
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  // Create a mock FirebaseAuth instance
  late MockFirebaseAuth authMock;

  setUp(() {
    authMock = MockFirebaseAuth();
  });

  testWidgets('Test create profile page', (WidgetTester tester) async {
    // Build the CreateProfilePage widget
    await tester.pumpWidget(MaterialApp(
      home: CreateProfilePage(userId: 'hHYhclWAdxXAAtjzhat5AzerC3Q2'), // Provide a userId for testing
    ));

    // Verify if 'Create Profile Page' text is present
    expect(find.text('Create Profile Page'), findsOneWidget);

  });
}
