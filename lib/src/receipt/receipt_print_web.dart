import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The browser print dialog (paper, 80 mm thermal printer or PDF) of a receipt page rendered in a
/// hidden frame, so no popup is opened and the app stays on screen.
bool get receiptPrintAvailable => true;

Future<void> printReceiptHtml(String html) async {
  final frame = web.HTMLIFrameElement()
    ..style.position = 'fixed'
    ..style.width = '0'
    ..style.height = '0'
    ..style.border = '0'
    ..style.right = '0'
    ..style.bottom = '0';
  final loaded = Completer<void>();
  frame.onload = ((web.Event _) {
    if (!loaded.isCompleted) loaded.complete();
  }).toJS;
  frame.srcdoc = html.toJS;
  web.document.body?.append(frame);
  await loaded.future.timeout(const Duration(seconds: 5), onTimeout: () {});
  try {
    frame.contentWindow?.focus();
    frame.contentWindow?.print();
  } finally {
    Timer(const Duration(minutes: 1), frame.remove);
  }
}
