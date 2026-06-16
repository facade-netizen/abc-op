import 'package:flutter/material.dart';

import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';

class BackLayTimeGapFilterOverlay extends StatefulWidget {
  const BackLayTimeGapFilterOverlay({
    super.key,
    this.onSubmitted,
  });
  final Function(Map<String, dynamic> filterValues)? onSubmitted;

  @override
  State<BackLayTimeGapFilterOverlay> createState() => _BackLayTimeGapFilterOverlayState();
}

class _BackLayTimeGapFilterOverlayState extends State<BackLayTimeGapFilterOverlay> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _triggerKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  final List<int> gapOptions = [1, 5, 10];
  int sameSelectionBL = 1;
  int diffSelectionBB = 1;
  int diffSelectionLL = 1;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _refreshFilters() {
    setState(() {
      sameSelectionBL = 1;
      diffSelectionBB = 1;
      diffSelectionLL = 1;
    });
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
          //onTap: _removeOverlay,
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
                    width: 400,
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setBodyState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  HighlightText(
                                    'Back / Lay Time Gap',
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

                            // Body
                            Container(
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildGapRow(
                                    label: 'Same Selection Back/Lay Time Gap <=',
                                    value: sameSelectionBL,
                                    onChanged: (value) {
                                      setBodyState(() {
                                        sameSelectionBL = value;
                                      });
                                    },
                                  ),
                                  _buildGapRow(
                                    label: 'Different Selection Back/Back Time Gap <=',
                                    value: diffSelectionBB,
                                    onChanged: (value) {
                                      setBodyState(() {
                                        diffSelectionBB = value;
                                      });
                                    },
                                  ),
                                  _buildGapRow(
                                    label: 'Different Selection Lay/Lay Time Gap <=',
                                    value: diffSelectionLL,
                                    onChanged: (value) {
                                      setBodyState(() {
                                        diffSelectionLL = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Footer Buttons
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
                                    action: () {
                                      _refreshFilters();
                                    },
                                  ),
                                  CustomECTAButton(
                                    title: 'Submit',
                                    action: () {
                                      final values = {
                                        'sameSelectionBL': sameSelectionBL, // actual time value
                                        'diffSelectionBB': diffSelectionBB, // actual time value
                                        'diffSelectionLL': diffSelectionLL, // actual time value
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

  Widget _buildGapRow({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: HighlightText(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            // Dropdown using MenuAnchor
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
                maximumSize: WidgetStateProperty.all(const Size(70, 400)),
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
              menuChildren: gapOptions.map((option) {
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
                    onChanged(option);
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
            const HighlightText('min(s)', style: TextStyle(fontSize: 12)),
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
          width: 180,
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
                  'Back / Lay Time Gap',
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
