import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/features/auth/presentation/login_screen.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('renders essential login controls', (tester) async {
    await pumpTestRoute(tester, path: '/login', child: const LoginScreen());
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text(AppStrings.signIn), findsOneWidget);
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);
  });

  testWidgets('empty submission shows required feedback', (tester) async {
    await pumpTestRoute(tester, path: '/login', child: const LoginScreen());
    final signIn = find.text(AppStrings.signIn);
    final button = find.ancestor(of: signIn, matching: find.byType(InkWell));
    tester.widget<InkWell>(button).onTap!();
    await tester.pump();
    expect(find.text('মোবাইল নম্বর ও পাসওয়ার্ড দিন।'), findsOneWidget);
  });

  testWidgets('invalid Bangladesh phone is rejected before network use',
      (tester) async {
    await pumpTestRoute(tester, path: '/login', child: const LoginScreen());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '01212345678');
    await tester.enterText(fields.at(1), 'password123');
    final signIn = find.text(AppStrings.signIn);
    final button = find.ancestor(of: signIn, matching: find.byType(InkWell));
    tester.widget<InkWell>(button).onTap!();
    await tester.pump();
    expect(find.text('সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন (01XXXXXXXXX)।'),
        findsOneWidget);
  });

  testWidgets('password visibility toggles obscureText', (tester) async {
    await pumpTestRoute(tester, path: '/login', child: const LoginScreen());
    EditableText field = tester.widget(find.byType(EditableText).at(1));
    expect(field.obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    field = tester.widget(find.byType(EditableText).at(1));
    expect(field.obscureText, isFalse);
  });
}
