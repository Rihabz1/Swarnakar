import 'package:swarnakar/shared/models/report_model.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final mockReports = [
  ReportModel(
    id: '1',
    type: AppStrings.goldCalculation,
    item: '২২ ক্যারেট · ১০ গ্রাম',
    date: '১৪ এপ্রিল ২০২৬',
    value: '৳ ১,৪৮,৫০০',
  ),
  ReportModel(
    id: '2',
    type: AppStrings.zakatCalculation,
    item: 'মোট সম্পদ হিসাব',
    date: '১৩ এপ্রিল ২০২৬',
    value: '৳ ২৫,৯৫৫',
  ),
  ReportModel(
    id: '3',
    type: AppStrings.silverCalculation,
    item: '২২ ক্যারেট · ৫০ গ্রাম',
    date: '১২ এপ্রিল ২০२६',
    value: '৳ ২,৮৫,০००',
  ),
  ReportModel(
    id: '4',
    type: AppStrings.goldCalculation,
    item: '২১ ক্যারেট · ২০ গ্রাম',
    date: '১০ এপ্রিল ২०२६',
    value: '৳ ৪,৭৩,৪००',
  ),
  ReportModel(
    id: '5',
    type: AppStrings.zakatCalculation,
    item: 'ত্রৈমাসিক হিসাব',
    date: '১ এপ্রিল २०२६',
    value: '৳ ৭৮,৩৫०',
  ),
];
