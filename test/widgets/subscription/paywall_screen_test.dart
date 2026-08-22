import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/features/subscription/presentation/paywall_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('shows all demo plans and premium benefits', (tester) async {
    await pumpTestRoute(
      tester,
      path: '/paywall',
      child: const PaywallScreen(),
    );

    expect(find.text('১ মাস'), findsOneWidget);
    expect(find.text('৩ মাস'), findsOneWidget);
    expect(find.text('৬ মাস'), findsOneWidget);
    expect(find.text('১ বছর'), findsOneWidget);
    expect(find.text('সেরা ভ্যালু'), findsOneWidget);
    expect(find.text(AppStrings.livePrices), findsOneWidget);
    expect(find.text(AppStrings.subscribeNow), findsOneWidget);
  });

  testWidgets('selecting a plan and subscribing enables demo entitlement',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTestRoute(
      tester,
      path: '/paywall',
      child: const PaywallScreen(),
      container: container,
    );

    await tester.tap(find.text('১ মাস'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.subscribeNow));
    await tester.pumpAndSettle();

    expect(container.read(isSubscribedProvider), isTrue);
    expect(find.text('TEST_DASHBOARD'), findsOneWidget);
  });

  testWidgets('guest continuation does not activate subscription',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTestRoute(
      tester,
      path: '/paywall',
      child: const PaywallScreen(),
      container: container,
    );

    await tester.tap(find.text(AppStrings.continueAsGuest));
    await tester.pumpAndSettle();

    expect(container.read(isSubscribedProvider), isFalse);
    expect(find.text('TEST_DASHBOARD'), findsOneWidget);
  });
}
