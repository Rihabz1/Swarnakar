import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/features/auth/presentation/forgot_password_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> submit(WidgetTester tester) async {
    final label = find.text('ওটিপি পাঠান');
    final button = find.ancestor(of: label, matching: find.byType(InkWell));
    tester.widget<InkWell>(button).onTap!();
    await tester.pump();
  }

  testWidgets('renders password recovery controls', (tester) async {
    await pumpTestRoute(
      tester,
      path: '/forgot-password',
      child: const ForgotPasswordScreen(),
    );
    expect(find.text('পাসওয়ার্ড রিসেট'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('ওটিপি পাঠান'), findsOneWidget);
  });

  testWidgets('empty and invalid phone show friendly validation',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/forgot-password',
      child: const ForgotPasswordScreen(),
    );
    await submit(tester);
    expect(find.text('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।'),
        findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '012-1234-5678');
    await submit(tester);
    expect(find.text('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।'),
        findsOneWidget);
  });
}
