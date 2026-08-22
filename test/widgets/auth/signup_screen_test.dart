import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/auth/presentation/signup_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> submit(WidgetTester tester) async {
    final label = find.text(AppStrings.createAccount);
    final button = find.ancestor(of: label, matching: find.byType(InkWell));
    tester.widget<InkWell>(button).onTap!();
    await tester.pump();
  }

  testWidgets('renders signup fields and Google option', (tester) async {
    await pumpTestRoute(tester, path: '/signup', child: const SignupScreen());

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text(AppStrings.createAccount), findsOneWidget);
    expect(find.text('Google দিয়ে চালিয়ে যান'), findsOneWidget);
  });

  testWidgets('requires every signup field', (tester) async {
    await pumpTestRoute(tester, path: '/signup', child: const SignupScreen());
    await submit(tester);
    expect(find.text('সবগুলো তথ্য দিন।'), findsOneWidget);
  });

  testWidgets('rejects invalid Bangladesh phone before network access',
      (tester) async {
    await pumpTestRoute(tester, path: '/signup', child: const SignupScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), '01212345678');
    await tester.enterText(fields.at(2), 'password1');
    await tester.enterText(fields.at(3), 'password1');
    await submit(tester);
    expect(find.text('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।'),
        findsOneWidget);
  });

  testWidgets('rejects short, spaced, and mismatched passwords',
      (tester) async {
    await pumpTestRoute(tester, path: '/signup', child: const SignupScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test User');
    await tester.enterText(fields.at(1), '01712345678');

    await tester.enterText(fields.at(2), 'short');
    await tester.enterText(fields.at(3), 'short');
    await submit(tester);
    expect(find.text('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।'), findsOneWidget);

    await tester.enterText(fields.at(2), 'pass word1');
    await tester.enterText(fields.at(3), 'pass word1');
    await submit(tester);
    expect(find.text('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।'), findsOneWidget);

    await tester.enterText(fields.at(2), 'password1');
    await tester.enterText(fields.at(3), 'password2');
    await submit(tester);
    expect(find.text('পাসওয়ার্ড মিলছে না।'), findsOneWidget);
  });

  testWidgets('sanitizes separators and limits phone input length',
      (tester) async {
    await pumpTestRoute(tester, path: '/signup', child: const SignupScreen());
    final phone = find.byType(TextFormField).at(1);
    await tester.enterText(phone, '+880 17-1234-567890');
    await tester.pump();
    expect(
        tester.widget<TextFormField>(phone).controller!.text, '8801712345678');
  });
}
