import 'package:swarnakar/shared/models/price_model.dart';
import 'package:swarnakar/core/constants/app_strings.dart';

final mockGoldPrices = [
  // Old gold prices (Bhangari)
  PriceModel(
    label: AppStrings.oldKarat22,
    price: 205333,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  PriceModel(
    label: AppStrings.oldKarat21,
    price: 196000,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  // Current market prices
  PriceModel(
    label: AppStrings.karat22,
    price: 248000,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  PriceModel(
    label: AppStrings.karat21,
    price: 236700,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  // Pure acid and pieces
  PriceModel(
    label: AppStrings.pureAcid,
    price: 224200,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
  PriceModel(
    label: AppStrings.pieceGold,
    price: 225400,
    unit: AppStrings.perBhori,
    updatedAt: AppStrings.lastUpdate,
  ),
];
