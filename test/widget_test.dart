import 'package:agl_quiz_flutter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders quiz title and buttons', (tester) async {
    await tester.pumpWidget(const QuizApp());

    expect(find.text('AGL Quiz App'), findsOneWidget);
    expect(find.text('Show Picture'), findsOneWidget);
    expect(find.text('Play Sound'), findsOneWidget);
  });
}

