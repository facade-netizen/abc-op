import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';

class BackLayOddsDifferentialOverlay extends StatefulWidget {
  const BackLayOddsDifferentialOverlay({
    super.key,
    this.onSubmitted,
  });
  final Function(Map<String, dynamic> filterValues)? onSubmitted;

  @override
  State<BackLayOddsDifferentialOverlay> createState() => _BackLayOddsDifferentialOverlayState();
}

class _BackLayOddsDifferentialOverlayState extends State<BackLayOddsDifferentialOverlay> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _triggerKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  StateSetter? _overlayStateSetter;

  final List<int> sameSelectionOptions = [5, 10, 20, 50, 100];
  final List<int> differentBackBackOptions = [2, 5, 8, 10];
  final List<int> differentLayLayOptions = [1, 2, 3, 5];

  // Track which switch is active: 0 = none, 1 = same selection, 2 = different back/back, 3 = different lay/lay
  int activeSwitch = 1;
  int sameSelectionGap = 5;
  int differentBackBackGap = 5;
  int differentLayLayGap = 1;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayStateSetter = null;
  }

  void _refreshFilters() {
    if (_overlayStateSetter != null) {
      _overlayStateSetter!.call(() {
        activeSwitch = 1;
        sameSelectionGap = 5;
        differentBackBackGap = 5;
        differentLayLayGap = 1;
      });
    } else {
      setState(() {
        activeSwitch = 0;
        sameSelectionGap = 5;
        differentBackBackGap = 5;
        differentLayLayGap = 1;
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }

    final renderBox = _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          // onTap: _removeOverlay,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                left: position.dx,
                top: position.dy + size.height - 100,
                child: Material(
                  elevation: 8,
                  child: Container(
                    width: 480,
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setBodyState) {
                        _overlayStateSetter = setBodyState;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  HighlightText(
                                    'Back / Lay Odds Differential',
                                    style: TextStyle(color: tileOrFontColor, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: _removeOverlay,
                                    child: Container(
                                      decoration: BoxDecoration(color: tileOrFontColor, borderRadius: BorderRadius.circular(4)),
                                      child: const Icon(Icons.close, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildToggleRow(
                                    switchId: 1,
                                    optionValues: sameSelectionOptions,
                                    label: 'Same Selection',
                                    isActive: activeSwitch == 1,
                                    onToggle: (value) {
                                      setBodyState(() {
                                        if (value) {
                                          activeSwitch = 1;
                                        } else {
                                          if (activeSwitch == 1) {
                                            activeSwitch = 0;
                                          }
                                        }
                                      });
                                    },
                                    description: 'Back / Lay Odds differential >=',
                                    value: sameSelectionGap,
                                    onValueChanged: (value) {
                                      setBodyState(() {
                                        sameSelectionGap = value;
                                      });
                                    },
                                    unit: '%',
                                  ),
                                  _buildToggleRow(
                                    switchId: 2,
                                    optionValues: differentBackBackOptions,
                                    label: 'Different Selection',
                                    isActive: activeSwitch == 2,
                                    onToggle: (value) {
                                      setBodyState(() {
                                        if (value) {
                                          activeSwitch = 2;
                                        } else {
                                          if (activeSwitch == 2) {
                                            activeSwitch = 0;
                                          }
                                        }
                                      });
                                    },
                                    description: 'Back/ Back Odds >=',
                                    value: differentBackBackGap,
                                    onValueChanged: (value) {
                                      setBodyState(() {
                                        differentBackBackGap = value;
                                      });
                                    },
                                    unit: 'odds',
                                  ),
                                  _buildToggleRow(
                                    switchId: 3,
                                    optionValues: differentLayLayOptions,
                                    label: 'Different Selection',
                                    isActive: activeSwitch == 3,
                                    onToggle: (value) {
                                      setBodyState(() {
                                        if (value) {
                                          activeSwitch = 3;
                                        } else {
                                          if (activeSwitch == 3) {
                                            activeSwitch = 0;
                                          }
                                        }
                                      });
                                    },
                                    description: 'Lay/ Lay Odds <=',
                                    value: differentLayLayGap,
                                    onValueChanged: (value) {
                                      setBodyState(() {
                                        differentLayLayGap = value;
                                      });
                                    },
                                    unit: 'odds',
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomOCTAButton(
                                    icon: Icons.refresh,
                                    title: 'Refresh',
                                    action: _refreshFilters,
                                  ),
                                  // BackLayOddsDifferentialOverlay ke Confirm button mein:
                                  CustomECTAButton(
                                    title: 'Confirm',
                                    action: () {
                                      final values = {
                                        'sameSelectionBL': activeSwitch == 1, // true/false
                                        'diffSelectionBB': activeSwitch == 2, // true/false
                                        'diffSelectionLL': activeSwitch == 3, // true/false
                                        // 'selectedValue': selectedValue,
                                      };
                                      widget.onSubmitted?.call(values);
                                      _removeOverlay();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildToggleRow({
    required int switchId,
    required String label,
    required bool isActive,
    required ValueChanged<bool> onToggle,
    required String description,
    required int value,
    required List<int> optionValues,
    required ValueChanged<int> onValueChanged,
    required String unit,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HighlightText(
              label,
              style: TextStyle(
                fontSize: 14,
                color: black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            FlutterSwitch(
              width: 60.0,
              height: 30.0,
              valueFontSize: 12.0,
              toggleSize: 18.0,
              value: isActive,
              borderRadius: 20.0,
              padding: 4.0,
              activeText: 'ON',
              inactiveText: 'OFF',
              showOnOff: true,
              activeColor: green,
              inactiveColor: grey,
              onToggle: onToggle,
            ),
            const SizedBox(width: 10),
            HighlightText(
              description,
              style: TextStyle(
                fontSize: 14,
                color: black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            MenuAnchor(
              style: MenuStyle(
                surfaceTintColor: WidgetStateProperty.all(white),
                shadowColor: WidgetStateProperty.all(Colors.black26),
                elevation: WidgetStateProperty.all(4.0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                    side: const BorderSide(color: Colors.black, width: 0.5),
                  ),
                ),
                maximumSize: WidgetStateProperty.all(const Size(70, 360)),
              ),
              builder: (context, controller, child) {
                return InkWell(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: white,
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HighlightText(
                            '$value',
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              },
              menuChildren: optionValues.map((option) {
                return MenuItemButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.grey.shade200;
                      }
                      return white;
                    }),
                  ),
                  onPressed: () {
                    onValueChanged(option);
                  },
                  child: SizedBox(
                    width: 35,
                    height: 30,
                    child: Row(
                      children: [
                        HighlightText(
                          '$option',
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 8),
            HighlightText(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        key: _triggerKey,
        onTap: _showOverlay,
        child: Container(
          width: 250,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500, width: 0.6),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: HighlightText(
                  'Back / Lay Odds Differential',
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
