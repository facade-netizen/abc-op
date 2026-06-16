import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;

import '../../../../bloc/fetchBlocs/fetch_premium_runner_wise_report_bloc.dart';
import '../../../../model/premium_runner_wise_report_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/loader.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../router/route_paths.dart';
import '../eventPlBook/event_pl_tile.dart';
import '../eventPlBook/user_rolls_tooltip.dart';
import '../runnerWiseReport/runner_wise_report_tile.dart';

class SbRunnerWiseReportView extends StatefulWidget {
  const SbRunnerWiseReportView({
    super.key,
    required this.marketId,
    required this.runnerName,
    required this.marketName,
    required this.userName,
  });
  final String marketId;
  final String marketName;
  final String runnerName;
  final String userName;
  @override
  State<SbRunnerWiseReportView> createState() => _SbRunnerWiseReportViewState();
}

class _SbRunnerWiseReportViewState extends State<SbRunnerWiseReportView> {
  PremiumRunnerWiseReportData report = PremiumRunnerWiseReportData(
    runnerName: '',
    eventName: '',
    detail: [],
  );
  @override
  void initState() {
    context.read<FetchPremiumRunnerWiseReportBloc>().add(
          FetchPremiumRunnerWiseReport(
            marketId: widget.marketId,
            runnerName: widget.runnerName,
            userName: widget.userName,
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      child: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<FetchPremiumRunnerWiseReportBloc, FetchPremiumRunnerWiseReportState>(
          builder: (context, fbs) {
            if (fbs is FetchPremiumRunnerWiseReportProgress) {
              return const LoaderContainerWithMessage();
            }

            if (fbs is FetchPremiumRunnerWiseReportSuccess) {
              report = fbs.reports;
            }

            return Column(
              children: [
                // Header Bar
                BookHeaderBar(eventName: report.eventName, eventType: widget.marketName),

                // Table Layout
                Expanded(child: SbPremiumRunnerWiseReportTile(report: report)),
              ],
            );
          },
        ),
      ),
    );
  }
}

final double hh = 60;

class SbPremiumRunnerWiseReportTile extends StatelessWidget {
  final PremiumRunnerWiseReportData report;
  const SbPremiumRunnerWiseReportTile({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    if (report.detail.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          hb15,
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Color(0xFF4a6170)),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Section:',
                  style: const TextStyle(color: Color(0xFFc6ccd1), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  report.runnerName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Table Header
          Container(
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
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: borderColor)),
                    ),
                    child: const HighlightText(
                      "UID",
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
                      "Last betting placed time",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
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
                              RWHCell(title: 'Avg. odds'),
                              RWHCell(title: 'Stake'),
                              RWHCell(title: 'Profit'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: report.detail.length,
              itemBuilder: (context, index) {
                final e = report.detail[index];

                return SbPremiumRunnerWiseReportRow(
                  detail: e,
                  index: index,
                  isLast: index == report.detail.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SbPremiumRunnerWiseReportRow extends StatelessWidget {
  final PremiumRunnerWiseReportDetail detail;
  final int index;
  final bool isLast;

  const SbPremiumRunnerWiseReportRow({
    super.key,
    required this.detail,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 24,
                      child: HighlightText(
                        "${index + 1}.",
                        style: const TextStyle(
                          color: Color(0xFFc6ccd1),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: UserRollsTT(
                          upLines: detail.upline,
                          child: GestureDetector(
                            onTap: () {
                              final baseUrl = html.window.location.origin;
                              final storageKey = 'user-report-upline-${detail.uuid}';
                              final uplineJson = jsonEncode(detail.upline.map((u) => {'name': u.name, 'title': u.title}).toList());
                              html.window.localStorage[storageKey] = uplineJson;
                              final url = '$baseUrl${RoutePaths.manageUserReport}?userName=${eqc(detail.uuid)}';
                              html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
                            },
                            child: HighlightText(
                              detail.uuid,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: blue,
                                color: blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: HighlightText(
                    formattedDate(detail.date),
                    style: const TextStyle(color: black, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    RWCell(val: detail.avgBackOdds),
                    RWCell(val: detail.backStake),
                    RWCell(val: detail.profit),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isLast ? borderColor : const Color(0xFFE4EBF1),
        ),
      ],
    );
  }
}
