import 'package:flutter/material.dart';

import '../../../reusable/colors.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/sized_box_hw.dart';

class Heading extends StatelessWidget {
  final String text;
  final bool isBold;
  const Heading(this.text, {super.key, this.isBold = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: HighlightText(text, style: TextStyle(color: black, fontSize: 14, fontWeight: isBold == true ? FontWeight.bold : FontWeight.normal)),
          ),
        ],
      ),
    );
  }
}

class CustomTabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CustomTabBtn(
    this.label, {
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? tileOrFontColor : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          border: Border(
            left: BorderSide(color: tileOrFontColor),
            right: BorderSide(color: tileOrFontColor),
            top: BorderSide(color: tileOrFontColor),
            bottom: isActive ? BorderSide(color: tileOrFontColor) : BorderSide.none,
          ),
        ),
        child: HighlightText(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? Colors.white : tileOrFontColor, height: 1),
        ),
      ),
    );
  }
}

class ExchangePlInfo extends StatelessWidget {
  const ExchangePlInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        hb12,
        const Heading(
          'Betting Profit & Loss enables you to review the bets you have placed.\n'
          'Specify the time period during which your bets were placed, '
          'the type of markets on which the bets were placed, and the sport.',
        ),
        const Heading('Betting Profit & Loss is available online for the past 62 days.'),
        const Heading('User can search up to 14 days records per query only.'),
      ],
    );
  }
}
