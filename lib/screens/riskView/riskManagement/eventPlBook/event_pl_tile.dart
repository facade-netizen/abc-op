import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

import '../../../../model/bm_book_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/sized_box_hw.dart';
import 'user_rolls_tooltip.dart';

final double hh = 60;

class BookHeaderBar extends StatelessWidget {
  final String eventName;
  final String eventType;

  const BookHeaderBar({
    super.key,
    required this.eventName,
    this.eventType = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hh - 20,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Color(0xFF1b2d37)),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                eventName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 10),
              if (eventType.isNotEmpty && eventName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    eventType,
                    style: const TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          InkWell(
            onTap: () {
              html.window.close();
            },
            child: const Row(
              children: [
                VerticalDivider(color: Colors.white, thickness: 1, width: 1),
                SizedBox(width: 10),
                Icon(Icons.close, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text("Close", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookTableLayout extends StatelessWidget {
  final List<BMBookData> book;
  final Function(BMBookData) onRowTap;

  const BookTableLayout({
    super.key,
    required this.book,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    bool hasDraw = book.isNotEmpty && book.any((b) => b.runners.any((r) => r.runnerName.toLowerCase().contains('draw')));

    double getRunnerNet(List<BMBookRunner> runners, int type) {
      if (runners.isEmpty) return 0;
      if (type == 0) return runners[0].net; // Team 1

      if (type == 1) {
        // Draw (X)
        var drawRunner = runners.where((r) => r.runnerName.toLowerCase().contains('draw'));
        if (drawRunner.isNotEmpty) return drawRunner.first.net;
        return 0;
      }

      if (type == 2) {
        // Team 2
        var team2 = runners.where((r) => !r.runnerName.toLowerCase().contains('draw')).toList();
        if (team2.length > 1) return team2[1].net;
        return 0;
      }
      return 0;
    }

    double totalR1 = book.fold(0, (sum, item) => sum + getRunnerNet(item.runners, 0));
    double totalR2 = book.fold(0, (sum, item) => sum + getRunnerNet(item.runners, 2));
    double totalR3 = book.fold(0, (sum, item) => sum + getRunnerNet(item.runners, 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          hb15,
          // Table Header
          Container(
            height: hh,
            decoration: const BoxDecoration(
              color: Color(0xFFEAEAEA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFB5B8C8)),
                top: BorderSide(color: Color(0xFFB5B8C8)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: borderColor)),
                    ),
                    child: const HighlightText(
                      "Downline",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFCDE0F5),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: hh / 2,
                          child: const Center(
                            child: HighlightText(
                              'Player P/L',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                                    '1',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                              if (hasDraw)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    alignment: Alignment.centerRight,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: borderColor)),
                                    ),
                                    child: const HighlightText(
                                      'X',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  child: const HighlightText(
                                    '2',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
          ),

          // Table Body
          Expanded(
            child: ListView(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: book.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFE4EBF1)),
                  itemBuilder: (context, index) {
                    final e = book[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 18,
                                  child: HighlightText(
                                    "${index + 1}.",
                                    style: const TextStyle(
                                      color: Color(0xFFc6ccd1),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: UserRollsTT(
                                      upLines: e.upLines,
                                      child: GestureDetector(
                                        onTap: () => onRowTap(e),
                                        child: HighlightText(
                                          e.name,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.25,
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
                            flex: 3,
                            child: Row(
                              children: [
                                // Runner 1 Data
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    alignment: Alignment.centerRight,
                                    child: HighlightText(
                                      formattedAmounts(getRunnerNet(e.runners, 0)),
                                      style: TextStyle(color: getRunnerNet(e.runners, 0) < 0 ? red : black, fontSize: 12),
                                    ),
                                  ),
                                ),
                                // Runner X Data
                                if (hasDraw)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.centerRight,
                                      child: HighlightText(
                                        formattedAmounts(getRunnerNet(e.runners, 1)),
                                        style: TextStyle(color: getRunnerNet(e.runners, 1) < 0 ? red : black, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                // Runner 2 Data
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    alignment: Alignment.centerRight,
                                    child: HighlightText(
                                      formattedAmounts(getRunnerNet(e.runners, 2)),
                                      style: TextStyle(color: getRunnerNet(e.runners, 2) < 0 ? red : black, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Table Footer (Total)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: const HighlightText(
                            "Total",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: black),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: HighlightText(
                                  formattedAmounts(totalR1),
                                  style: TextStyle(color: totalR1 < 0 ? red : black, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                            if (hasDraw)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  child: HighlightText(
                                    formattedAmounts(totalR3),
                                    style: TextStyle(color: totalR3 < 0 ? red : black, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: HighlightText(
                                  formattedAmounts(totalR2),
                                  style: TextStyle(color: totalR2 < 0 ? red : black, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                hb15,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
