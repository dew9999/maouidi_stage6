import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maouidi/components/empty_state_widget.dart';

void main() {
  testWidgets('EmptyStateWidget renders icon, title, and message',
      (WidgetTester tester) async {
    const testIcon = Icons.search_off;
    const testTitle = 'No Results';
    const testMessage = 'Try adjusting your filters.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            icon: testIcon,
            title: testTitle,
            message: testMessage,
          ),
        ),
      ),
    );

    // Verify icon
    expect(find.byIcon(testIcon), findsOneWidget);
    // Verify title
    expect(find.text(testTitle), findsOneWidget);
    // Verify message
    expect(find.text(testMessage), findsOneWidget);
  });
}
