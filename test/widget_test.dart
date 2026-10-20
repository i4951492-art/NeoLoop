import 'package:flutter_test/flutter_test.dart';
import 'package:neoloop/main.dart';
void main(){testWidgets('home renders',(tester)async{await tester.pumpWidget(const NeoLoopApp());await tester.pumpAndSettle();expect(find.text('NeoLoop'),findsOneWidget);expect(find.text('ИГРАТЬ'),findsOneWidget);});}
