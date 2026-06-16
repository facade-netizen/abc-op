import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import '../../../apis/apiHandlers/api_constants.dart';
import '../../../constants/html_templates.dart';
import '../../../model/casino_history_model.dart';
import '../../../reusable/highlighted_text_widget.dart';

Future<void> showCasinoProfitDetailsDialog(BuildContext context, GameReport item) async {
  if (kIsWeb) {
    await _openBalanceHistoryPopup(item);
    return;
  }

  return showDialog(
    context: context,
    builder: (context) => const Center(child: HighlightText('API version only implemented for Web')),
  );
}

Future<void> _openBalanceHistoryPopup(GameReport item) async {
  final history = item.detail.map((d) {
    final betTime = d.betTime != null
        ? '${d.betTime!.year.toString().padLeft(4, '0')}/${d.betTime!.month.toString().padLeft(2, '0')}/${d.betTime!.day.toString().padLeft(2, '0')} ${d.betTime!.hour.toString().padLeft(2, '0')}:${d.betTime!.minute.toString().padLeft(2, '0')}:${d.betTime!.second.toString().padLeft(2, '0')}'
        : '';
    return {
      'reference': d.roundId,
      'betTime': betTime,
      'gameName': item.name,
      'gameStatus': 'SETTLE',
      'round': d.round,
      'betType': 'Casino',
      'bet': d.bet,
      'win': d.win,
      'totalPL': d.pnl,
      'result': '▶',
      'transactionId': d.transactionId,
    };
  }).toList();

  final pageTitle = history.isNotEmpty ? 'Transaction Report - ${item.name} : ${item.detail.first.betTime?.toIso8601String().split('T').first ?? ''}' : 'Transaction Report';

  web.window.localStorage['casino_report_data'] = jsonEncode(history);
  web.window.localStorage['casino_report_title'] = pageTitle;

  final template = await rootBundle.loadString(AppHtmlTemplates.casinoDetails);
  final pageHtml = template.replaceAll('{{PAGE_TITLE}}', pageTitle).replaceAll('{{CASINO_VIDEO_VIEW}}', CGApiConstants.baseUrl + CGApiConstants.betDetail);
  
  final availW = web.window.screen.availWidth;
  final availH = web.window.screen.availHeight;
  final left = ((availW - 1180) / 2).floor();
  final top = ((availH - 760) / 2).floor();
  final features = 'popup=yes,resizable=yes,scrollbars=yes,width=1180,height=760,left=$left,top=$top';
  final popup = web.window.open('', '_blank', features);
  if (popup == null) return;

  popup.document.open();
  popup.document.write(pageHtml.toJS);
  popup.document.close();
}
