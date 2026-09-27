import 'package:flutter_test/flutter_test.dart';
import 'package:mailcraftai/core/constants/app_constants.dart';
import 'package:mailcraftai/app/app.dart';

void main() {
  testWidgets('MailCraft AI branding initial load test', (WidgetTester tester) async {
    // Build MailCraftApp and trigger initial frame.
    await tester.pumpWidget(const MailCraftApp());

    // Verify splash screen displays MailCraft AI branding & tagline
    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text(AppConstants.tagline), findsWidgets);

    // Pump timer to allow splash screen to transition cleanly to HomeScreen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify home screen displays app bar logo title
    expect(find.text(AppConstants.appName), findsWidgets);
  });
}
