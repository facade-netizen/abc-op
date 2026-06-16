import 'package:flutter/material.dart';

import '../../../../reusable/colors.dart';
import '../../../../reusable/highlighted_text_widget.dart';

double blw(BuildContext context) {
  Size size = MediaQuery.sizeOf(context);
  return size.width * 0.070;
}

class SportsBookHeader extends StatelessWidget {
  const SportsBookHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
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
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const TableHeaderCell(text: 'Matched Amount'),
                ],
              ),
            ),
          ),
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
