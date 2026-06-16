import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

import '../../../../model/sport_wise_report_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../router/route_paths.dart';

final double hh = 60;

class SportWiseReportTile extends StatelessWidget {
  final List<SportWiseReportData> report;
  final int type;
  final String userName;
  const SportWiseReportTile({super.key, required this.report, required this.type, required this.userName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: report.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(color: Color(0xFF4a6170)),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        formattedOnlyDate(e.date),
                        style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                // Table Header
                SwHeader(),
                // Table Body
                report.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: HighlightText('No data', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ),
                      )
                    : Column(
                        children: e.detail.map((detail) {
                          return SportWiseReportRow(
                            type: type,
                            userName: userName,
                            detail: detail,
                            index: e.detail.indexOf(detail),
                            isLast: e.detail.indexOf(detail) == e.detail.length - 1,
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SportWiseReportRow extends StatelessWidget {
  final Detail detail;
  final int index;
  final bool isLast;
  final int type;
  final String userName;
  const SportWiseReportRow({super.key, required this.detail, required this.index, required this.isLast, required this.type, required this.userName});

  @override
  Widget build(BuildContext context) {
    ///
    String eventType = type == 0
        ? 'Match Odds'
        : type == 2
        ? 'Bookmaker'
        : '';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          final baseUrl = html.window.location.origin;
                          final url =
                              '$baseUrl${RoutePaths.manageRunnerWiseReport}?eventType=${eqc(eventType)}&marketId=${eqc(detail.marketId)}&runnerId=${eqc(detail.runnerId)}&userName=${eqc(userName)}';
                          html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                        },
                        child: HighlightText(
                          detail.eventName,
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, decoration: TextDecoration.underline, decorationColor: blue, color: blue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(Icons.play_arrow, size: 18, color: grey.withOpacity(0.3)),
                    HighlightText(
                      getReportType(detail.marketType, originalType: detail.marketTypeString),
                      style: TextStyle(color: blue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: HighlightText(formattedDate(detail.runnerName), style: const TextStyle(color: black, fontSize: 12)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    SwCell(value: detail.avgBackOdds),
                    SwCell(
                      value: detail.backStake,
                      color: backType,
                      onTap: () {
                        final baseUrl = html.window.location.origin;
                        final url =
                            '$baseUrl${RoutePaths.manageRunnerWiseReport}?eventType=${eqc(eventType)}&marketId=${eqc(detail.marketId)}&runnerId=${eqc(detail.runnerId)}&userName=${eqc(userName)}';
                        html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    SwCell(value: detail.avgLayOdds),
                    SwCell(
                      value: detail.layStake,
                      color: layType,
                      onTap: () {
                        final baseUrl = html.window.location.origin;
                        final url =
                            '$baseUrl${RoutePaths.manageRunnerWiseReport}?eventType=${eqc(eventType)}&marketId=${eqc(detail.marketId)}&runnerId=${eqc(detail.runnerId)}&userName=${eqc(userName)}';
                        html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: isLast ? borderColor : const Color(0xFFE4EBF1)),
      ],
    );
  }
}

class SwCell extends StatelessWidget {
  const SwCell({super.key, required this.value, this.color, this.onTap});
  final double value;
  final Color? color;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(right: 10),
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: onTap,
          child: HighlightText(
            formattedAmounts(value),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color ?? black, fontSize: 12, decoration: TextDecoration.underline, decorationColor: color ?? white),
          ),
        ),
      ),
    );
  }
}

class SwHeader extends StatelessWidget {
  const SwHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hh,
      decoration: const BoxDecoration(
        color: Color(0xFFEAEAEA),
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: borderColor)),
              ),
              child: const HighlightText(
                "Event name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: borderColor)),
              ),
              child: const HighlightText(
                "Selection name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFCDE0F5),
                border: Border(right: BorderSide(color: borderColor)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: hh / 2,
                    child: const Center(
                      child: HighlightText(
                        'Back',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
                      ),
                    ),
                  ),
                  const Divider(color: borderColor, height: 0.5, thickness: 1),
                  SizedBox(
                    height: hh / 2 - 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: borderColor)),
                            ),
                            child: const HighlightText(
                              'Avg. odds',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: black),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            child: const HighlightText(
                              'Stake',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9D1D5),
                border: Border(right: BorderSide(color: borderColor)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: hh / 2,
                    child: const Center(
                      child: HighlightText(
                        'Lay',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
                      ),
                    ),
                  ),
                  const Divider(color: borderColor, height: 0.5, thickness: 1),
                  SizedBox(
                    height: hh / 2 - 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: borderColor)),
                            ),
                            child: const HighlightText(
                              'Avg. odds',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: black),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            child: const HighlightText(
                              'Stake',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
