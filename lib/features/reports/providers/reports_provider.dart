import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/shared/models/report_model.dart';
import 'package:swarnakar/features/reports/data/reports_mock.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final activeReportFilterProvider = StateProvider<String>((ref) => AppStrings.all);

final allReportsProvider = Provider<List<ReportModel>>((ref) {
  return mockReports;
});

final filteredReportsProvider = Provider<List<ReportModel>>((ref) {
  final filter = ref.watch(activeReportFilterProvider);
  final allReports = ref.watch(allReportsProvider);

  if (filter == AppStrings.all) {
    return allReports;
  }

  return allReports.where((report) {
    if (filter == AppStrings.gold) {
      return report.type.contains(AppStrings.gold);
    } else if (filter == AppStrings.silver) {
      return report.type.contains(AppStrings.silver);
    } else if (filter == AppStrings.zakat) {
      return report.type.contains(AppStrings.zakat);
    }
    return true;
  }).toList();
});
