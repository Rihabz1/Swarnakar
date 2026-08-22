import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/core/providers/core_providers.dart';
import 'package:swarnakar/shared/models/user_model.dart';

void main() {
  UserModel profile({
    required bool subscribed,
    DateTime? expires,
  }) {
    return UserModel(
      uid: 'qa-user',
      name: 'QA User',
      email: '',
      phone: '01712345678',
      shopName: '',
      address: '',
      isSubscribed: subscribed,
      plan: subscribed ? 'yearly' : '',
      subExpires: expires,
    );
  }

  Future<bool> readEntitlement({
    UserModel? user,
    bool localFallback = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        userProfileProvider.overrideWith((ref) async => user),
      ],
    );
    addTearDown(container.dispose);
    container.read(isSubscribedProvider.notifier).state = localFallback;
    await container.read(userProfileProvider.future);
    return container.read(activeSubscriptionProvider);
  }

  test('guest without a profile is not subscribed', () async {
    expect(await readEntitlement(), isFalse);
  });

  test('unsubscribed profile is not active', () async {
    expect(
      await readEntitlement(user: profile(subscribed: false)),
      isFalse,
    );
  });

  test('subscribed profile without expiry remains active', () async {
    expect(
      await readEntitlement(user: profile(subscribed: true)),
      isTrue,
    );
  });

  test('future subscription expiry is active', () async {
    expect(
      await readEntitlement(
        user: profile(
          subscribed: true,
          expires: DateTime.now().add(const Duration(days: 1)),
        ),
      ),
      isTrue,
    );
  });

  test('past subscription expiry is inactive', () async {
    expect(
      await readEntitlement(
        user: profile(
          subscribed: true,
          expires: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
      isFalse,
    );
  });

  test('local paywall fallback temporarily enables entitlement', () async {
    expect(
      await readEntitlement(
        user: profile(subscribed: false),
        localFallback: true,
      ),
      isTrue,
    );
  });
}
