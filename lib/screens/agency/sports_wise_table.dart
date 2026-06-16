import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/fetchBlocs/fetch_lt_report_bloc.dart';
import '../../model/life_time_report_model.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';

class SportsWiseTable extends StatelessWidget {
  const SportsWiseTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchLtReportBloc, FetchLtReportState>(
      builder: (context, lrs) {
        List<LifeTimeReport> ltReportData = [];
        String lifetimeCreatedTime = '';
        if (lrs is FetchLtReportSuccess) {
          ltReportData = lrs.ltReportData;
          lifetimeCreatedTime = lrs.createdTime;
        }
        final formattedLifetimeCreatedTime = formatLifetimeCreatedDate(lifetimeCreatedTime);
        return ltReportData.isEmpty
            ? SizedBox()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lifetime Record Date
                  HighlightText(
                    'Lifetime Record Started From: $formattedLifetimeCreatedTime',
                    style: TextStyle(fontWeight: FontWeight.w500, color: black),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ltReportData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final sport = entry.value;
                      final isCasino = sport.type == 4;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: index == 0 ? 0 : 20),
                          // sports name
                          HighlightText(
                            sport.bettingType,
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: red),
                          ),
                          const SizedBox(height: 4),
                          SportsWiseHeaderRow(isCasino: isCasino),
                          // Table Rows
                          sport.detailData.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: white,
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  ),
                                  child: Padding(padding: const EdgeInsets.only(left: 8), child: const HighlightText('No Data')),
                                )
                              : Column(
                                  children: sport.detailData.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final data = entry.value;
                                    final isLast = index == sport.detailData.length - 1;
                                    return SportsWiseDataRow(data: data, isCasino: isCasino, isLast: isLast);
                                  }).toList(),
                                ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
      },
    );
  }
}

String formattedVal(double value) {
  final formatter = NumberFormat('#,##0.00');
  final formattedValue = formatter.format(value.abs());
  return formattedValue;
}

String formatLifetimeCreatedDate(String value) {
  if (value.trim().isEmpty) return value;

  final supportedFormats = <DateFormat>[
    DateFormat('dd:MM:yyyy HH:mm:ss'),
    DateFormat('dd-MM-yyyy HH:mm:ss'),
    DateFormat('yyyy-MM-dd HH:mm:ss'),
    DateFormat('yyyy/MM/dd HH:mm:ss'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
  ];

  DateTime? parsed;
  for (final format in supportedFormats) {
    try {
      parsed = format.parseStrict(value);
      break;
    } catch (_) {}
  }

  parsed ??= DateTime.tryParse(value);
  if (parsed == null) return value;

  return DateFormat('yyyy-MM-dd').format(parsed);
}

class SportsWiseCell extends StatelessWidget {
  const SportsWiseCell({super.key, required this.title, this.isHeader = false, this.color});
  final String title;
  final bool isHeader;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return HighlightText(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: color ?? black, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
    );
  }
}

class SportsWiseHeaderRow extends StatelessWidget {
  const SportsWiseHeaderRow({super.key, required this.isCasino});
  final bool isCasino;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: SportsWiseCell(title: 'Product', isHeader: true)),
          Expanded(flex: 3, child: SportsWiseCell(title: 'Ticket Counts${isCasino ? '' : ' (back/lay)'}', isHeader: true)),
          Expanded(flex: 4, child: SportsWiseCell(title: 'Turnover${isCasino ? '' : ' (total (back/lay))'}', isHeader: true)),
          Expanded(flex: 4, child: SportsWiseCell(title: 'Profit/Loss${isCasino ? '' : ' (total (back/lay))'}', isHeader: true)),
          Expanded(flex: 4, child: SportsWiseCell(title: 'Margin${isCasino ? '' : ' (total (back/lay))'}', isHeader: true)),
          Expanded(flex: 2, child: SportsWiseCell(title: 'Commission', isHeader: true)),
        ],
      ),
    );
  }
}

class SportsWiseDataRow extends StatelessWidget {
  const SportsWiseDataRow({super.key, required this.data, required this.isCasino, this.isLast = false});

  final LifeTimeReportDetail data;
  final bool isCasino, isLast;

  TextSpan valueSpan(double value) {
    return TextSpan(
      text: formattedVal(value),
      style: TextStyle(fontSize: 12, height: 1.25, fontWeight: FontWeight.w300, color: value < 0 ? red : black),
    );
  }

  WidgetSpan symbolSpan(String symbol) {
    return WidgetSpan(alignment: PlaceholderAlignment.middle, child: Text(symbol));
  }

  Widget richCell({required int flex, required List<InlineSpan> spans}) {
    return Expanded(
      flex: flex,
      child: HighlightText.rich(
        '',
        textAlign: TextAlign.center,
        textSpan: TextSpan(children: spans),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: isLast ? borderColor : Colors.grey.shade200)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(flex: 2, child: SportsWiseCell(title: data.name)),
            richCell(flex: 3, spans: isCasino ? [valueSpan(data.backCount)] : [valueSpan(data.backCount), symbolSpan('/'), valueSpan(data.layCount)]),
            richCell(
              flex: 4,
              spans: isCasino
                  ? [valueSpan(data.totalBackStack)]
                  : [valueSpan(data.totalStack), symbolSpan('('), valueSpan(data.totalBackStack), symbolSpan('/'), valueSpan(data.totalLayStack), symbolSpan(')')],
            ),
            richCell(
              flex: 4,
              spans: isCasino
                  ? [valueSpan(data.totalBackMtm)]
                  : [valueSpan(data.totalMtm), symbolSpan('('), valueSpan(data.totalBackMtm), symbolSpan('/'), valueSpan(data.totalLayMtm), symbolSpan(')')],
            ),
            richCell(
              flex: 4,
              spans: isCasino
                  ? [valueSpan(data.marginBack), symbolSpan('%')]
                  : [valueSpan(data.marginTotal), symbolSpan('% ('), valueSpan(data.marginBack), symbolSpan('% /'), valueSpan(data.marginLay), symbolSpan('% )')],
            ),
            richCell(flex: 2, spans: [valueSpan(data.commission)]),
          ],
        ),
      ),
    );
  }
}
