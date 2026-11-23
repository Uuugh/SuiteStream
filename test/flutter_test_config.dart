import 'dart:async';

import 'package:suitestream/src/ui/cancel_save_pair.dart';

/// Tests tap Cancel | Save and expect the dialog to be gone at once, so the
/// DEF-01 "Saved / Cancelled" hold is off by default. Tests of the hold itself set
/// `CancelSavePair.debugHold` or `holdDuration` explicitly.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  CancelSavePair.debugHold = Duration.zero;
  await testMain();
}
