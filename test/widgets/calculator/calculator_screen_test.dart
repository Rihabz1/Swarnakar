import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/calculator/presentation/calculator_screen.dart';
import 'package:swarnakar/features/calculator/providers/calculator_provider.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('does not show result before calculation', (tester) async {
    await pumpTestRoute(tester,
        path: '/calculator', child: const CalculatorScreen());
    expect(find.text(AppStrings.totalPrice), findsNothing);
  });

  testWidgets('calculates and renders all result categories', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await pumpTestRoute(tester,
        path: '/calculator',
        child: const CalculatorScreen(),
        container: container);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10');
    await tester.enterText(fields.at(1), '7500');
    await tester.enterText(fields.at(2), '1200');
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pump();
    expect(find.text(AppStrings.metalValue), findsOneWidget);
    expect(find.text(AppStrings.labor), findsOneWidget);
    expect(find.text(AppStrings.totalPrice), findsOneWidget);
    expect(container.read(calculatorResultProvider)?['totalValue'], 76200);
  });

  testWidgets('zero weight keeps result hidden', (tester) async {
    await pumpTestRoute(tester,
        path: '/calculator', child: const CalculatorScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '7500');
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pump();
    expect(find.text(AppStrings.totalPrice), findsNothing);
  });
}
