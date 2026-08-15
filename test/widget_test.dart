// Basic Flutter widget test for NIS Digital Store.

import 'package:flutter_test/flutter_test.dart';
import 'package:nis_digital_store/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NISDigitalStoreApp());
    // Verify splash screen renders
    expect(find.text('NIS Digital Store'), findsOneWidget);
  });
}
