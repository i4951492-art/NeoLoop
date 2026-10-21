import 'package:flutter_test/flutter_test.dart';
import 'package:neoloop/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    // Просто проверяем, что виджет создаётся без падения
    await tester.pumpWidget(const NeoLoopApp());
    
    // Не ждём асинхронную загрузку — тест только на то, что приложение стартует
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
