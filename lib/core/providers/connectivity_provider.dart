import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarnakar/core/utils/connectivity_helper.dart';

final internetConnectionProvider = StreamProvider<bool>((ref) async* {
  yield await ConnectivityHelper.isConnected();

  await for (final _ in ConnectivityHelper.connectivityStream) {
    yield await ConnectivityHelper.isConnected();
  }
});

Future<void> requireInternet(Ref ref) async {
  final hasInternet = await ref.watch(internetConnectionProvider.future);
  if (!hasInternet) {
    throw const NetworkException();
  }
}

Stream<T> networkBlockedStream<T>(Ref ref) async* {
  await requireInternet(ref);
}
