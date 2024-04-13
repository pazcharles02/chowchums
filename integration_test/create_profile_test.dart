import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chowchums/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Creating a new user with profile creation ',
          (tester) async {
        app.main();
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds:1));
        await tester.tap(find.byType(TextButton));
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byKey(const Key('emailTextField')),'integrationtest@gmail.com');
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byType(TextField).at(1), '123456');
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byType(TextField).at(2), '123456');
        await Future.delayed(const Duration(seconds:1));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), 'integration test');
        await Future.delayed(const Duration(seconds:1));
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sushi'));
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byType(TextField).at(1), '1999-11-11');
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byType(TextField).at(2), 'vancouver');
        await Future.delayed(const Duration(seconds:1));
        await tester.enterText(find.byType(TextField).at(3), 'Hello this is an integration test.');
        await Future.delayed(const Duration(seconds:1));
        await tester.ensureVisible(find.byKey(const Key('saveProfile')));
        await Future.delayed(const Duration(seconds:1));
        await tester.tap(find.byKey(const Key('saveProfile')));
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds:2));
        expect(find.byType(BottomNavigationBar),findsOneWidget);
        },
    );
  });
}