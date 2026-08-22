import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/features/auth/presentation/otp_screen.dart';
import 'package:swarnakar/features/auth/presentation/reset_password_screen.dart';

import '../../helpers/test_app.dart';

Future<void> pressGoldenButton(WidgetTester tester, String text) async {
  final label = find.text(text);
  final button = find.ancestor(of: label, matching: find.byType(InkWell));
  tester.widget<InkWell>(button).onTap!();
  await tester.pump();
}

void main() {
  testWidgets('reset OTP screen masks phone and rejects incomplete code',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/otp',
      child: const OtpScreen(phone: '01712345678', flow: 'reset'),
    );

    expect(find.text('পাসওয়ার্ড রিসেট OTP'), findsOneWidget);
    expect(find.text('017*****78'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
    await pressGoldenButton(tester, 'OTP যাচাই করুন');
    expect(find.text('৬ সংখ্যার সঠিক OTP দিন।'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('signup OTP screen gives a friendly empty-code message',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/otp',
      child: const OtpScreen(phone: '123', flow: 'signup'),
    );
    expect(find.text('123'), findsOneWidget);
    await pressGoldenButton(tester, 'যাচাই করুন ও এগিয়ে যান');
    expect(find.text('OTP দিন।'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('complete reset OTP advances to password entry', (tester) async {
    await pumpTestRoute(
      tester,
      path: '/otp',
      child: const OtpScreen(phone: '01712345678', flow: 'reset'),
    );
    final boxes = find.byType(TextField);
    for (var index = 0; index < 6; index++) {
      await tester.enterText(boxes.at(index), '${index + 1}');
    }
    await pressGoldenButton(tester, 'OTP যাচাই করুন');
    await tester.pumpAndSettle();
    expect(find.text('TEST_RESET_PASSWORD'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('reset password validates required and short values',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/reset-password',
      child: const ResetPasswordScreen(phone: '01712345678', otp: '123456'),
    );
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await pressGoldenButton(tester, 'পাসওয়ার্ড আপডেট করুন');
    expect(
        find.text('নতুন পাসওয়ার্ড ও কনফার্ম পাসওয়ার্ড দিন।'), findsOneWidget);

    await tester.enterText(fields.at(0), 'short');
    await tester.enterText(fields.at(1), 'short');
    await pressGoldenButton(tester, 'পাসওয়ার্ড আপডেট করুন');
    expect(find.text('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।'), findsOneWidget);
  });

  testWidgets('reset password rejects spaces and mismatched confirmation',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/reset-password',
      child: const ResetPasswordScreen(phone: '01712345678', otp: '123456'),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'pass word1');
    await tester.enterText(fields.at(1), 'pass word1');
    await pressGoldenButton(tester, 'পাসওয়ার্ড আপডেট করুন');
    expect(find.text('পাসওয়ার্ডে স্পেস ব্যবহার করা যাবে না।'), findsOneWidget);

    await tester.enterText(fields.at(0), 'password1');
    await tester.enterText(fields.at(1), 'password2');
    await pressGoldenButton(tester, 'পাসওয়ার্ড আপডেট করুন');
    expect(find.text('পাসওয়ার্ড মিলছে না।'), findsOneWidget);
  });

  testWidgets('reset password requires a previously verified OTP',
      (tester) async {
    await pumpTestRoute(
      tester,
      path: '/reset-password',
      child: const ResetPasswordScreen(phone: '01712345678', otp: ''),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'password1');
    await tester.enterText(fields.at(1), 'password1');
    await pressGoldenButton(tester, 'পাসওয়ার্ড আপডেট করুন');
    expect(find.text('OTP পাওয়া যায়নি। আবার OTP যাচাই করুন।'), findsOneWidget);
  });
}
