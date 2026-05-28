import 'package:flutter_test/flutter_test.dart';

import 'package:safe/main.dart';

void main() {
  testWidgets('SafeApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeApp());

    // Verify the app renders without errors.
    expect(find.byType(SafeApp), findsOneWidget);
  });
}
