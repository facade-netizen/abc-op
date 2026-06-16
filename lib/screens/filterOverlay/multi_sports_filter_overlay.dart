import 'package:flutter/material.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import 'filter_overlay_button.dart';

class MultiSportsFilterOverlay extends StatefulWidget {
  final double width;
  final Function(Map<String, dynamic> filterValues)? onSubmitted;

  const MultiSportsFilterOverlay({
    super.key,
    required this.width,
    this.onSubmitted,
  });

  @override
  State<MultiSportsFilterOverlay> createState() => _MultiSportsFilterOverlayState();
}

class _MultiSportsFilterOverlayState extends State<MultiSportsFilterOverlay> {
  final List<String> multiSportsDropdownList = [
    'S/R Soccer',
    'BOOK Soccer',
    'S/R Tennis',
    'BOOK Tennis',
    'Cricket/Fancy Bet',
    'S/R Cricket',
    'BOOK Cricket',
    'Election/Fancy Bet',
    'S/R E-Soccer',
  ];
  late void Function(void Function()) _setBodyState;

  /// Always lowercase
  Set<String> selectedSports = {};

  void _refreshFilters() {
    _setBodyState(() {
      selectedSports.clear();
    });
    setState(() {
      selectedSports.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterOverlay(
      width: widget.width,
      title: 'Sports Filter',
      refreshTitle: 'Clear All',
      onRefresh: _refreshFilters,
      onSubmitted: (_) {
        widget.onSubmitted?.call({
          'selectedSports': selectedSports.toList(),
        });
      },
      body: StatefulBuilder(
        builder: (context, setBodyState) {
          // store reference
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setBodyState = setBodyState;
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              multiSportsDropdownList.length,
              (index) {
                final sport = multiSportsDropdownList[index];
                final sportValue = sport.toLowerCase();
                final isChecked = selectedSports.contains(sportValue);

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                      top: index == 0 ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                    ),
                    color: white,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setBodyState(() {
                            if (value == true) {
                              selectedSports.add(sportValue);
                            } else {
                              selectedSports.remove(sportValue);
                            }
                          });
                        },
                      ),
                      HighlightText(
                        sport,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
