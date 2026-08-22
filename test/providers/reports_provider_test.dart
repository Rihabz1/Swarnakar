import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/reports/providers/reports_provider.dart';
import 'package:swarnakar/shared/models/report_model.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('all filter returns every report', () {
    final all = container.read(allReportsProvider);

    expect(container.read(filteredReportsProvider), same(all));
  });

  final filterCases = [
    (AppStrings.gold, AppStrings.goldCalculation, 2),
    (AppStrings.silver, AppStrings.silverCalculation, 1),
    (AppStrings.zakat, AppStrings.zakatCalculation, 2),
  ];

  for (final (filter, expectedType, expectedCount) in filterCases) {
    test('$filter filter returns only matching reports', () {
      container.read(activeReportFilterProvider.notifier).state = filter;

      final results = container.read(filteredReportsProvider);

      expect(results, hasLength(expectedCount));
      expect(results.every((report) => report.type == expectedType), isTrue);
    });
  }

  test('unknown filter safely falls back to all reports', () {
    container.read(activeReportFilterProvider.notifier).state = 'unknown';

    expect(
      container.read(filteredReportsProvider),
      hasLength(container.read(allReportsProvider).length),
    );
  });

  test('can be isolated from bundled mock data with a provider override', () {
    final customReport = ReportModel(
      id: 'qa-1',
      type: AppStrings.goldCalculation,
      item: 'Boundary fixture',
      date: '2026-01-01',
      value: '৳ 1',
    );
    final isolated = ProviderContainer(
      overrides: [
        allReportsProvider.overrideWithValue([customReport]),
      ],
    );
    addTearDown(isolated.dispose);

    expect(isolated.read(filteredReportsProvider), [customReport]);
  });
}
