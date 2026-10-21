import 'package:flutter_test/flutter_test.dart';
import 'package:neoloop/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Просто проверяем, что приложение запускается
    await tester.pumpWidget(const NeoLoopApp());
    await tester.pumpAndSettle();

    // Проверяем, что на экране есть название игры
    expect(find.text('NeoLoop'), findsOneWidget);
  });
}
