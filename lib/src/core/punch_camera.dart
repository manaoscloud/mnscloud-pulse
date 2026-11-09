import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Takes the photo of a mark with the front camera (on the web the browser camera or file
/// chooser). Small JPEG: the photo proves presence, it is not a document. `null` = no photo.
typedef PunchPhotoCapture = Future<Uint8List?> Function();

Future<Uint8List?> capturePunchPhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    maxWidth: 960,
    maxHeight: 960,
    imageQuality: 70,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return bytes.isEmpty ? null : bytes;
}

/// Replaced only by tests; the app always uses [capturePunchPhoto].
PunchPhotoCapture punchPhotoCapture = capturePunchPhoto;
