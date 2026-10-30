import 'location.dart';

/// Platforms without a location implementation record the punch without location.
Future<PunchLocation?> currentPunchLocation() async => null;
