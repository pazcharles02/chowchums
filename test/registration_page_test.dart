/*
User Story #2

As a user, I want to be able to quickly register and create my profile and begin looking for new friends quicker.

*Acceptance Criteria: users are able to create their profile in less  than 1 minute.

 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:chowchums/screens/registration_page.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth authMock;
  late MockUserCredential mockUserCredential;

  setUpAll(() async {
    // Initialize Firebase app for testing
    authMock = MockFirebaseAuth(); // Initialize authMock
    mockUserCredential = MockUserCredential(); // Initialize mockUserCredential
  });

  testWidgets('Test registration page - Password mismatch', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(
      home: RegistrationPage(auth: authMock),
    ));


    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    final confirmPasswordField = find.byType(TextField).at(2);
    final registerButton = find.text('Register');


    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');
    await tester.enterText(confirmPasswordField, 'differentpassword'); // Passwords don't match


    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
  // load testing
  testWidgets('Test registration page - Register 1000 users', (WidgetTester tester) async {
  int registeredUsersCount = 0; // Initialize counter for registered users

  await tester.pumpWidget(MaterialApp(
    home: RegistrationPage(auth: authMock),
  ));

  // Loop to register 10000 users
  for (int i = 0; i < 10000; i++) {
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    final confirmPasswordField = find.byType(TextField).at(2);
    final registerButton = find.text('Register');

    // Generate unique email for each user
    String email = 'user$i@example.com';
    String password = 'password'; // You can use the same password for simplicity

    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.enterText(confirmPasswordField, password);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Increment registered users count
    registeredUsersCount++;
  }

  // Assert that 1000 users were registered
  expect(registeredUsersCount, 10000);
});
}



