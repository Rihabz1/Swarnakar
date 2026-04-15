import 'package:swarnakar/shared/models/price_model.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final mockSilverPrices = [
  // New silver prices
  PriceModel(
    label: AppStrings.newSilverKarat22,
    price: 5700,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  PriceModel(
    label: AppStrings.newSilverKarat21,
    price: 5400,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  // Silver and acid kaim
  PriceModel(
    label: AppStrings.silverRopya,
    price: 3700,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  PriceModel(
    label: AppStrings.acidKaim,
    price: 3800,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
];
