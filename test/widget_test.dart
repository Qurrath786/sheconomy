import 'package:flutter_test/flutter_test.dart';
import 'package:sheconomy/app.dart';

void main() {
  testWidgets('SHEconomy app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SHEconomyApp());
  });
}
