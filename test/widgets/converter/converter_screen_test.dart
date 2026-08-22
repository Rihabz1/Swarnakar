// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/converter/presentation/converter_screen.dart';
import '../../helpers/test_app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('bn_BD'));

  testWidgets('shows references and empty initial result', (tester) async {
    await pumpTestRoute(tester,
        path: '/converter', child: const ConverterScreen());
    expect(find.text('-- ' + AppStrings.bhoriUnit), findsOneWidget);
    expect(find.textContaining('১১.৬৬৪'), findsOneWidget);
  });

  testWidgets('converts bhori-equivalent grams', (tester) async {
    await pumpTestRoute(tester,
        path: '/converter', child: const ConverterScreen());
    await tester.enterText(find.byType(TextFormField), '11.664');
    await tester.pump();
    expect(find.text('১ ' + AppStrings.bhoriUnit), findsOneWidget);
  });

  testWidgets('swap reverses selected units', (tester) async {
    await pumpTestRoute(tester,
        path: '/converter', child: const ConverterScreen());
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();
    final dropdownFinder =
        find.byWidgetPredicate((widget) => widget is DropdownButton<String>);
    final values = tester
        .widgetList<DropdownButton<String>>(dropdownFinder)
        .map((item) => item.value)
        .toList();
    expect(values, [AppStrings.bhoriUnit, AppStrings.gramUnit]);
  });
}
