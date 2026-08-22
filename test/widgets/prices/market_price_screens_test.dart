import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';
import 'package:swarnakar/features/gold_price/presentation/gold_price_screen.dart';
import 'package:swarnakar/features/gold_price/providers/gold_price_provider.dart';
import 'package:swarnakar/features/silver_price/presentation/silver_price_screen.dart';
import 'package:swarnakar/features/silver_price/providers/silver_price_provider.dart';
import 'package:swarnakar/shared/models/price_model.dart';

import '../../helpers/test_app.dart';

void main() {
  final price = PriceModel(
    label: '২২ ক্যারেট',
    price: 123456,
    unit: 'ভরি',
    updatedAt: '2026-08-23T01:00:00.000Z',
  );

  final guestOverrides = <Override>[
    userProfileProvider.overrideWith((ref) async => null),
  ];

  testWidgets('gold market renders data and guest subscription prompt',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/gold-price',
      child: const GoldPriceScreen(),
      overrides: [
        ...guestOverrides,
        goldPricesBySection.overrideWithValue(
          AsyncData({
            'নতুন স্বর্ণ': [price]
          }),
        ),
      ],
    );

    expect(find.text('নতুন স্বর্ণ'), findsOneWidget);
    expect(find.text('২২ ক্যারেট'), findsOneWidget);
    expect(find.text('প্রিমিয়ামে আপগ্রেড করুন'), findsOneWidget);
  });

  testWidgets('gold market shows a friendly offline state', (tester) async {
    await pumpTestRoute(
      tester,
      path: '/gold-price',
      child: const GoldPriceScreen(),
      overrides: [
        ...guestOverrides,
        goldPricesBySection.overrideWithValue(
          const AsyncError(NetworkException(), StackTrace.empty),
        ),
      ],
    );

    expect(find.text('ইন্টারনেট সংযোগ নেই'), findsOneWidget);
    expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
  });

  testWidgets('gold market hides technical errors behind friendly copy',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/gold-price',
      child: const GoldPriceScreen(),
      overrides: [
        ...guestOverrides,
        goldPricesBySection.overrideWithValue(
          AsyncError(Exception('database detail'), StackTrace.empty),
        ),
      ],
    );

    expect(find.text('তথ্য লোড করা যায়নি'), findsOneWidget);
    expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
    expect(find.textContaining('database detail'), findsNothing);
  });

  testWidgets('market screens explain when no current prices exist',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/gold-price',
      child: const GoldPriceScreen(),
      overrides: [
        ...guestOverrides,
        goldPricesBySection.overrideWithValue(const AsyncData({})),
      ],
    );
    expect(find.text('এই মুহূর্তে স্বর্ণের মূল্য পাওয়া যাচ্ছে না।'),
        findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await pumpTestRoute(
      tester,
      path: '/silver-price',
      child: const SilverPriceScreen(),
      overrides: [
        ...guestOverrides,
        silverPricesBySection.overrideWithValue(const AsyncData({})),
      ],
    );
    expect(find.text('এই মুহূর্তে রৌপ্যের মূল্য পাওয়া যাচ্ছে না।'),
        findsOneWidget);
  });

  testWidgets('silver market renders data and handles offline failures',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/silver-price',
      child: const SilverPriceScreen(),
      overrides: [
        ...guestOverrides,
        silverPricesBySection.overrideWithValue(
          AsyncData({
            'নতুন রৌপ্য': [price]
          }),
        ),
      ],
    );

    expect(find.text('নতুন রৌপ্য'), findsOneWidget);
    expect(find.text('২২ ক্যারেট'), findsOneWidget);

    await pumpTestRoute(
      tester,
      path: '/silver-price',
      child: const SilverPriceScreen(),
      overrides: [
        ...guestOverrides,
        silverPricesBySection.overrideWithValue(
          const AsyncError(NetworkException(), StackTrace.empty),
        ),
      ],
    );
    expect(find.text('ইন্টারনেট সংযোগ নেই'), findsOneWidget);
  });
}
