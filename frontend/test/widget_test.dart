import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JobTrackerApp());
    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
