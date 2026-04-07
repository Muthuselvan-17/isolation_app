import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/main.dart';

void main() {
  testWidgets('Counter increment smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ABCDogTrackingApp()));

    // Verify that our app starts at Login screen (looking for 'Login' button text)
    expect(find.text('Login'), findsOneWidget);
  });
}
