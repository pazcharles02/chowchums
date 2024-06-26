/*
User Story #3
As a user, I expect my personal information to be securely stored and transmitted, using encryption methods to protect against unauthorized access along with a secure login.

*Acceptance Criteria: Functional authorization services for login like use of SSO services like Google or Facebook
 */


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:chowchums/screens/login_page.dart'; // Import the LoginPage widget


// Mock FirebaseAuth instance using Mockito
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  // Create a mock FirebaseAuth instance
  // ignore: unused_local_variable
  late MockFirebaseAuth authMock;

  setUp(() {
    authMock = MockFirebaseAuth();
  });

  testWidgets('Test login page text fields', (WidgetTester tester) async {
  // Build the LoginPage widget
  await tester.pumpWidget(const MaterialApp(
    home: LoginPage(),
  ));

  // Simulate entering text in the username field
  await tester.enterText(find.byType(TextField).at(0), 'test@example.com');

  // Verify that the text field contains the entered text
  expect(find.text('test@example.com'), findsOneWidget);

  // Simulate entering text in the password field
  await tester.enterText(find.byType(TextField).at(1), 'password');

  // Verify that the text field contains the entered text
  expect(find.text('password'), findsOneWidget);

  await tester.tap(find.byKey(const Key('login_button')));

  await tester.pumpAndSettle();

});
  
}