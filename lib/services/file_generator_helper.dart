import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:convert';

Future<Uint8List> runPdfWorker(Map<String, dynamic> payload) {
  final completer = Completer<Uint8List>();

  final worker = web.Worker('workers/pdf_worker.js'.toJS);

  final jsPayload = payload.jsify() as JSAny;

  worker.postMessage(jsPayload);

  worker.onmessage = (web.MessageEvent event) {
    final data = event.data;

    if (data == null) {
      completer.completeError("Invalid worker response");
      worker.terminate();
      return;
    }

    final jsMap = data.dartify() as Map?;

    if (jsMap == null || jsMap["success"] != true) {
      completer.completeError(jsMap?["error"] ?? "Unknown worker error");
      worker.terminate();
      return;
    }

    final jsBytes = jsMap["bytes"];

    try {
      final uint8 = Uint8List.view(jsBytes);
      completer.complete(uint8);
    } catch (e) {
      if (kDebugMode) debugPrint('File generator helper: $e');
      completer.completeError("Worker returned invalid bytes");
    }

    worker.terminate();
  }.toJS;

  worker.onerror = ((JSAny? error) {
    completer.completeError("Worker error: $error");
    worker.terminate();
  }).toJS;

  return completer.future;
}

/// save and launch file in pdf
Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final anchor = web.HTMLAnchorElement()
    ..href = "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}"
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
