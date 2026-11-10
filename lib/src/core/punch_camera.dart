import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'punch_camera_io.dart'
    if (dart.library.js_interop) 'punch_camera_web.dart'
    as platform;

/// Takes the photo of a mark with the front camera, live: the native camera on phones, the
/// browser camera stream on the web (never a file chooser, so an old picture cannot be sent).
/// Small JPEG: the photo proves presence, it is not a document. `null` = no photo.
typedef PunchPhotoCapture = Future<Uint8List?> Function(BuildContext context);

Future<Uint8List?> capturePunchPhoto(BuildContext context) =>
    platform.capturePunchPhoto(context);

/// Replaced only by tests; the app always uses [capturePunchPhoto].
PunchPhotoCapture punchPhotoCapture = capturePunchPhoto;
