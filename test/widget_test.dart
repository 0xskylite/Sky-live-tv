import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylivetv/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('app launches and shows home header',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SkyLiveTvApp());
    await tester.pump();
    expect(find.text('SKY LIVE TV'), findsOneWidget);
  });
}
