import 'dart:async';
import 'dart:io';

Future<T> withRetry<T>(
  Future<T> Function() action, {
  int retries = 2,
  Duration delay = const Duration(seconds: 1),
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await action();
    } on SocketException {
      if (attempt >= retries) rethrow;
    } on TimeoutException {
      if (attempt >= retries) rethrow;
    }
    attempt++;
    await Future.delayed(delay * attempt);
  }
}

Stream<T> withStreamRetry<T>(
  Stream<T> Function() streamFactory, {
  Duration delay = const Duration(seconds: 2),
}) async* {
  while (true) {
    try {
      yield* streamFactory();
      return;
    } catch (_) {
      await Future.delayed(delay);
    }
  }
}
