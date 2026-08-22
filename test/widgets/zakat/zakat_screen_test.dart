import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/zakat/presentation/zakat_screen.dart';
import 'package:swarnakar/features/zakat/providers/zakat_provider.dart';
import '../../helpers/test_app.dart';

void main() {
  final nisab = zakatNisabProvider.overrideWith((ref) => Stream.value({
        'gold_nisab': 895200.0,
        'silver_nisab': 52860.0,
      }));

  testWidgets('renders provided nisab data', (tester) async {
    await pumpTestRoute(tester,
        path: '/zakat', child: const ZakatScreen(), overrides: [nisab]);
    await tester.pump();
    expect(find.text(AppStrings.nisabLimit), findsOneWidget);
    expect(find.textContaining('স্বর্ণ নিসাব:'), findsOneWidget);
  });

  testWidgets('exact silver nisab is eligible', (tester) async {
    await pumpTestRoute(tester,
        path: '/zakat', child: const ZakatScreen(), overrides: [nisab]);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(2), '52860');
    final button = find.text(AppStrings.calculateZakat);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(find.text(AppStrings.zakatEligible), findsOneWidget);
  });

  testWidgets('one taka below silver nisab is not eligible', (tester) async {
    await pumpTestRoute(tester,
        path: '/zakat', child: const ZakatScreen(), overrides: [nisab]);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(2), '52859');
    final button = find.text(AppStrings.calculateZakat);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(find.text(AppStrings.nisabNotMet), findsOneWidget);
  });
}
