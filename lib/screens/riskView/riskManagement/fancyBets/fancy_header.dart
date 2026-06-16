import 'package:flutter/material.dart';

import '../../../../reusable/colors.dart';
import '../../../../reusable/highlighted_text_widget.dart';

double mmw(BuildContext context) {
  Size size = MediaQuery.sizeOf(context);
  return size.width * 0.100;
}

class FancyHeader extends StatelessWidget {
  const FancyHeader({super.key});
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
          PlayerPLHeader(),
          const FBBooks(),
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
  const PlayerPLHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          width: mmw(context) * 2,
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
          width: mmw(context) * 2,
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
                    'MIN',
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
                    'MAX',
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

class FBBooks extends StatelessWidget {
  const FBBooks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 80,
      decoration: const BoxDecoration(color: Color(0xFFE4E4E4)),
      child: Center(
        child: HighlightText(
          'Books',
          style: TextStyle(color: tileOrFontColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class BooksButton extends StatelessWidget {
  const BooksButton({super.key, required this.isLast, required this.isExpanded, this.onTap});
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
              color: amber,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: amber, width: 2),
            ),
            child: const Center(
              child: HighlightText(
                'Books',
                style: TextStyle(color: tileOrFontColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarketNameCard extends StatelessWidget {
  const MarketNameCard({
    super.key,
    required this.isLast,
    required this.isExpanded,
    required this.eventName,
    required this.type,
    this.onExpandToggle,
    this.onTap,
  });
  final bool isLast, isExpanded;
  final String eventName, type;
  final void Function()? onTap;
  final void Function()? onExpandToggle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: isExpanded ? BorderSide.none : BorderSide(color: isLast ? borderColor : Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            onExpandToggle == null
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: InkWell(
                      onTap: onExpandToggle,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: grey),
                        ),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                          color: black,
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: onTap,
                child: HighlightText(
                  eventName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: blue,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: blue,
                  ),
                ),
              ),
            ),
            if (type.isNotEmpty)
              Icon(
                Icons.play_arrow,
                size: 18,
                color: grey.withOpacity(0.3),
              ),
            HighlightText(
              type,
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
