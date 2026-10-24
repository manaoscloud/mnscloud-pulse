import 'package:flutter/foundation.dart';

/// Official time shown to the employee: the device clock corrected by the offset measured against
/// the server (GET /pulse/time and every session answer). Online punches use the server clock
/// anyway; the corrected time matters for marks taken offline.
class ServerClock extends ChangeNotifier {
  Duration _offset = Duration.zero;
  bool _measured = false;

  Duration get offset => _offset;
  bool get measured => _measured;

  void accept(DateTime serverTime, {DateTime? deviceNow}) {
    _offset = serverTime.toUtc().difference(
      (deviceNow ?? DateTime.now()).toUtc(),
    );
    _measured = true;
    notifyListeners();
  }

  DateTime nowUtc() => DateTime.now().toUtc().add(_offset);
}
