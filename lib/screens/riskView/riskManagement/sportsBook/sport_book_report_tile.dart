import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as html;

import '../../../../bloc/fetchBlocs/fetch_open_premium_sport_bloc.dart';
import '../../../../model/premium_sport_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/loader.dart';
import '../../../../router/route_paths.dart';
import '../eventPlBook/event_pl_tile.dart';

class SportBookReportView extends StatefulWidget {
  const SportBookReportView({
    super.key,
    required this.sportName,
    required this.userName,
  });
  final String sportName;
  final String userName;
  @override
  State<SportBookReportView> createState() => _SportBookReportViewState();
}

class _SportBookReportViewState extends State<SportBookReportView> {
  List<PremiumSportData> report = [];
  @override
  void initState() {
    context.read<FetchOpenPremiumSportBloc>().add(FetchOpenPremiumSport(sportName: widget.sportName, userName: widget.userName));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      child: Align(
        alignment: Alignment.topCenter,
        child: BlocBuilder<FetchOpenPremiumSportBloc, FetchOpenPremiumSportState>(
          builder: (context, fbs) {
            if (fbs is FetchOpenPremiumSportProgress) {
              return const LoaderContainerWithMessage();
            }

            if (fbs is FetchOpenPremiumSportSuccess) {
              report = fbs.data;
            }

            return Column(
              children: [
                // Header Bar
                BookHeaderBar(eventName: widget.sportName),

                // Table Layout
                Expanded(child: SportBookReportTile(report: report, userName: widget.userName)),
              ],
            );
          },
        ),
      ),
    );
  }
}

final double hh = 60;

class SportBookReportTile extends StatelessWidget {
  final List<PremiumSportData> report;
  final String userName;
  const SportBookReportTile({
    super.key,
    required this.report,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: report.map(
        (e) {
          return Column(
            children: e.dateDetail.map(
              (d) {
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
                                formattedOnlyDate(d.date),
                                style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        // Table Header
                        SwHeader(),
                        // Table Body
                        d.details.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: HighlightText(
                                    'No data',
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              )
                            : Column(
                                children: d.details.map(
                                  (detail) {
                                    return SportBookReportRow(
                                      detail: detail,
                                      index: d.details.indexOf(detail),
                                      isLast: d.details.indexOf(detail) == d.details.length - 1,
                                      userName: userName,
                                    );
                                  },
                                ).toList(),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          );
        },
      ).toList(),
    );
  }
}

class SportBookReportRow extends StatefulWidget {
  final PremiumDetail detail;
  final int index;
  final bool isLast;
  final String userName;
  const SportBookReportRow({
    super.key,
    required this.detail,
    required this.index,
    required this.isLast,
    required this.userName,
  });

  @override
  State<SportBookReportRow> createState() => _SportBookReportRowState();
}

class _SportBookReportRowState extends State<SportBookReportRow> {
  void openRunnerDetails() {
    final baseUrl = html.window.location.origin;
    final url =
        '$baseUrl${RoutePaths.manageSportBookRunnerWiseReport}?marketId=${eqc(widget.detail.marketId)}&runnerName=${eqc(widget.detail.runnerName)}&eventName=${eqc(widget.detail.eventName)}&marketName=${eqc(widget.detail.marketName)}&userName=${eqc(widget.userName)}';
    html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: openRunnerDetails,
                        child: HighlightText(
                          widget.detail.eventName,
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
                    if (widget.detail.marketName.isNotEmpty) ...[
                      Icon(
                        Icons.play_arrow,
                        size: 18,
                        color: grey.withOpacity(0.3),
                      ),
                      HighlightText(
                        widget.detail.marketName,
                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: HighlightText(
                    formattedDate(widget.detail.runnerName),
                    style: const TextStyle(color: black, fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    SwCell(value: widget.detail.avgOdd),
                    SwCell(
                      value: widget.detail.matchedAmount,
                      color: backType,
                      onTap: openRunnerDetails,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: widget.isLast ? borderColor : const Color(0xFFE4EBF1),
        ),
      ],
    );
  }
}

class SwCell extends StatelessWidget {
  const SwCell({
    super.key,
    required this.value,
    this.color,
    this.onTap,
  });
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
            style: TextStyle(
              color: color ?? black,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: color ?? white,
            ),
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
        ],
      ),
    );
  }
}
