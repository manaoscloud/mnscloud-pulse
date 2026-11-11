/// Native builds print through the system share sheet in a later phase; the web prints now.
bool get receiptPrintAvailable => false;

Future<void> printReceiptHtml(String html) async {}
