import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neoloop/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const NeoLoopApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
