import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import '../../constants/html_templates.dart';
import '../../model/agency_model.dart';
import '../../reusable/formatters.dart';
import '../../reusable/highlighted_text_widget.dart';

Future<void> showUserCommissionHtml(BuildContext context, AgencyModel user) async {
  if (kIsWeb) {
    await _openUserCommissionPopup(user);
    return;
  }

  return showDialog(
    context: context,
    builder: (context) => const Center(
      child: HighlightText('HTML commission view is available only on Web'),
    ),
  );
}

Future<void> _openUserCommissionPopup(AgencyModel user) async {
  final template = await rootBundle.loadString(AppHtmlTemplates.userCommission);
  final pageHtml = template
      .replaceAll('{{USER_NAME}}', user.userName)
      .replaceAll('{{EXPOSURE_LIMIT}}', formattedAmounts(user.exposureLimit))
      .replaceAll('{{COMMISSION_RATE}}', '${formattedAmounts(user.commissionRate)}%')
      .replaceAll('{{MAX_LOSS_LIMIT}}', formattedAmounts(0));

  final availW = web.window.screen.availWidth;
  final availH = web.window.screen.availHeight;
  final targetW = (availW * 0.5).floor();
  final targetH = (availH * 0.5).floor();
  final left = ((availW - targetW) / 2).floor();
  final top = ((availH - targetH) / 2).floor();
  final features = 'popup=yes,resizable=yes,scrollbars=yes,width=$targetW,height=$targetH,left=$left,top=$top';

  final popup = web.window.open('', '_blank', features);
  if (popup == null) return;

  popup.document.open();
  popup.document.write(pageHtml.toJS);
  popup.document.close();
}
