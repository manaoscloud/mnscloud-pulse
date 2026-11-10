import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Native camera (front), never the gallery.
Future<Uint8List?> capturePunchPhoto(BuildContext context) async {
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
