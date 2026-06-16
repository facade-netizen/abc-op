import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants/html_templates.dart';
import '../../../../reusable/highlighted_text_widget.dart';

class FancyBookEntry {
  final String runs;
  final double amount;
  FancyBookEntry({required this.runs, required this.amount});
}

Future<dynamic> showFancyBookViewWithData(BuildContext context, {required String matchTitle, String tag = '', required String runnerName, required List<FancyBookEntry> data}) {
  if (kIsWeb) {
    try {
      _openFancyBookPopup(matchTitle, tag, runnerName, data);
      return Future.value();
    } catch (_) {}
  }

  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => const Center(child: HighlightText('API version only implemented for Web')),
  );
}

Future<void> _openFancyBookPopup(String matchTitle, String tag, String runnerName, List<FancyBookEntry> data) async {
  final initialRows = StringBuffer();
  for (var d in data) {
    final amt = d.amount >= 0 ? '\$${d.amount.toStringAsFixed(2)}' : '(\$${d.amount.abs().toStringAsFixed(2)})';
    final cls = d.amount >= 0 ? 'positive' : 'negative';
    initialRows.write(
      '<tr class="$cls">'
      '<td>${d.runs}</td>'
      '<td style="text-align:right;">$amt</td>'
      '</tr>',
    );
  }

  final jsonData = jsonEncode(data.map((d) => {'runs': d.runs, 'amount': d.amount}).toList()).replaceAll('</', '<\\/');
  final template = await rootBundle.loadString(AppHtmlTemplates.fancyBookDetails);
  final popupHtml = template
      .replaceAll('{{MATCH_TITLE}}', matchTitle)
      .replaceAll('{{TAG}}', tag)
      .replaceAll('{{SAFE_JSON}}', jsonData)
      .replaceAll('{{TABLE_ROWS}}', initialRows.toString());

  final availW = web.window.screen.availWidth;
  final availH = web.window.screen.availHeight;
  final targetW = (availW * 0.5).floor();
  final targetH = (availH * 0.8).floor();
  final left = ((availW - targetW) / 2).floor();
  final top = ((availH - targetH) / 2).floor();
  final features = 'popup=yes,resizable=yes,scrollbars=yes,width=$targetW,height=$targetH,left=$left,top=$top';
  final popup = web.window.open('', '_blank', features);
  if (popup == null) return;
  popup.document.open();
  popup.document.write(popupHtml.toJS);
  popup.document.close();
}

