import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Sistema de Asistencia CUA'),
        ),
      ),
    );

    expect(find.text('Sistema de Asistencia CUA'), findsOneWidget);
  });
}
