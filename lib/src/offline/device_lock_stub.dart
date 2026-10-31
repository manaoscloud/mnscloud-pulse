Future<void>? _tail;

/// Runs [task] after the previous one; while idle no future is kept.
Future<T> withDeviceLock<T>(Future<T> Function() task) {
  final previous = _tail;
  final run = previous == null ? task() : previous.then((_) => task());
  late final Future<void> tail;
  tail = run.then<void>((_) {}, onError: (_) {}).whenComplete(() {
    if (identical(_tail, tail)) _tail = null;
  });
  _tail = tail;
  return run;
}

void onBrowserOnline(void Function() listener) {}

/// Tests only: a task of a finished test zone never completes, so the queue starts empty again.
void resetDeviceLock() => _tail = null;
