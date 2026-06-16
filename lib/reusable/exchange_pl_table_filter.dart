import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'formatters.dart';
import 'highlighted_text_widget.dart';

class ExchangePlTableFilter extends StatelessWidget {
  const ExchangePlTableFilter({
    super.key,
    required this.totalPL,
    required this.dropdownItems,
    required this.selectedSport,
    required this.onSportChanged,
  });

  final double totalPL;
  final List<String> dropdownItems;
  final String selectedSport;
  final ValueChanged<String?> onSportChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: Row(
        children: [
          Row(
            children: [
              HighlightText(
                'Total P/L:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: black),
              ),
              const SizedBox(width: 5),
              HighlightText(
                formattedAmounts(totalPL),
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: totalPL < 0 ? red : black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (dropdownItems.isNotEmpty)
            SizedBox(
              height: 32,
              width: 160,
              child: DropdownButtonFormField2<String>(
                iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down, color: black)),
                value: dropdownItems.contains(selectedSport) ? selectedSport : 'ALL',
                isExpanded: true,
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: white,
                  contentPadding: const EdgeInsets.only(left: 10, right: 4),
                  hintStyle: TextStyle(color: grey, fontSize: 14),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: blue, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: grey),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  elevation: 0,
                  offset: const Offset(0, 0),
                  maxHeight: ((dropdownItems.isNotEmpty ? dropdownItems.length : 1) * 30) + 20,
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(color: black),
                  ),
                ),
                items: dropdownItems
                    .map(
                      (sport) => DropdownMenuItem<String>(
                        value: sport,
                        child: Text(
                          sport,
                          style: const TextStyle(fontSize: 14, color: black),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onSportChanged,
              ),
            ),
          const SizedBox(width: 8),
          HighlightText(
            formattedAmounts(totalPL),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: totalPL < 0 ? red : black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
