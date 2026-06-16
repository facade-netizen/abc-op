import 'package:flutter/material.dart';

import '../../../../reusable/colors.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../fancyBets/fancy_header.dart';

class SportsTableHeader extends StatelessWidget {
  const SportsTableHeader({super.key, required this.sid});
  final int sid;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 10,
          ),
          SizedBox(width: 150, child: const TableHeaderCell(text: 'Sports')),
          SizedBox(width: 150, child: const TableHeaderCell(text: 'Market Date')),
          Expanded(flex: 8, child: const TableHeaderCell(text: 'Event/Market Name')),
          PlayerPLHeader(sid: sid),
          const DownlinePLHeader(),
        ],
      ),
    );
  }
}

class TableHeaderCell extends StatelessWidget {
  final String text;

  const TableHeaderCell({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: HighlightText(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class PlayerPLHeader extends StatelessWidget {
  const PlayerPLHeader({super.key, required this.sid});
  final int sid;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          width: mmw(context) * (sid == 1 ? 3 : 2),
          decoration: const BoxDecoration(
            color: plColor,
            border: Border(
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: const Center(
            child: HighlightText(
              'Player P/L',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        Container(
          height: 30,
          width: mmw(context) * (sid == 1 ? 3 : 2),
          decoration: const BoxDecoration(
            color: plColor,
            border: Border(
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: mmw(context) - 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: HighlightText(
                    '1',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              if (sid == 1)
                SizedBox(
                  width: mmw(context) - 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: HighlightText(
                      'X',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              SizedBox(
                width: mmw(context) - 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: HighlightText(
                    '2',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DownlinePLHeader extends StatelessWidget {
  const DownlinePLHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 80,
      decoration: const BoxDecoration(color: Color(0xFFE4E4E4)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HighlightText(
              'Downline',
              style: TextStyle(color: tileOrFontColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            HighlightText(
              'P/L',
              style: TextStyle(color: tileOrFontColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewButton extends StatelessWidget {
  const ViewButton({super.key, required this.isLast, this.isExpanded = false, this.onTap});
  final void Function()? onTap;
  final bool isLast, isExpanded;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: white,
          border: Border(bottom: isExpanded ? BorderSide.none : BorderSide(color: isLast ? borderColor : Colors.grey.shade200)),
        ),
        width: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: grey),
            ),
            child: const Center(
              child: HighlightText(
                'View',
                style: TextStyle(color: tileOrFontColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoData extends StatelessWidget {
  const NoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: Color(0xFFBDBDBD))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Center(
            child: HighlightText(
              'No Data',
              style: TextStyle(color: grey),
            ),
          ),
        ],
      ),
    );
  }
}
