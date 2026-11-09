import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openPrivateFile(
  List<int> bytes,
  String contentType,
  String fileName,
) async {
  try {
    final dir = await getTemporaryDirectory();
    final safe = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/${safe.isEmpty ? 'documento' : safe}');
    await file.writeAsBytes(bytes, flush: true);
    return await launchUrl(Uri.file(file.path));
  } catch (_) {
    return false;
  }
}
