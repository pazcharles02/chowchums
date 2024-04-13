import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chowchums/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Verify login screen with correct username and password',
            (tester) async {
            app.main();
            await tester.pumpAndSettle();
            await Future.delayed(const Duration(seconds:2));
            await tester.enterText(find.byType(TextField).at(0), 'spongebob@gmail.com');
            await Future.delayed(const Duration(seconds:2));
            await tester.enterText(find.byType(TextField).at(1), '123456');
            await Future.delayed(const Duration(seconds:2));
            await tester.tap(find.byType(ElevatedButton));
            await Future.delayed(const Duration(seconds:2));
            await tester.pumpAndSettle();
            expect(find.byType(BottomNavigationBar),findsOneWidget);
          },
        );
  });
}