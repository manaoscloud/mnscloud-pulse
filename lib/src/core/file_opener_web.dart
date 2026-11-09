import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<bool> openPrivateFile(
  List<int> bytes,
  String contentType,
  String fileName,
) async {
  final blob = web.Blob(
    [Uint8List.fromList(bytes).toJS].toJS,
    web.BlobPropertyBag(type: contentType),
  );
  final url = web.URL.createObjectURL(blob);
  // A blocked pop-up still lets the browser save the file.
  if (web.window.open(url, '_blank') == null) {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    anchor.click();
  }
  Timer(const Duration(minutes: 2), () => web.URL.revokeObjectURL(url));
  return true;
}
