import 'package:flutter/material.dart';

import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/style.dart';

// Reusable Filter Overlay Widget
class FilterOverlay extends StatefulWidget {
  final double width;
  final double? bodyWidth;
  final double maxHeight;
  final String title;
  final String refreshTitle;
  final Widget body;
  final Function(Map<String, dynamic> filterValues)? onSubmitted;
  final VoidCallback? onRefresh;

  const FilterOverlay({
    super.key,
    required this.width,
    required this.title,
    required this.refreshTitle,
    required this.body,
    this.onSubmitted,
    this.onRefresh,
    this.bodyWidth,
    this.maxHeight = 400,
  });

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 32),
                child: Material(
                  elevation: 5,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: widget.bodyWidth ?? 300,
                    constraints: BoxConstraints(maxHeight: widget.maxHeight),
                    child: Column(
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
                                widget.title,
                                style: TextStyle(color: tileOrFontColor, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: _toggleOverlay,
                                child: Container(
                                  decoration: BoxDecoration(color: tileOrFontColor, borderRadius: BorderRadius.circular(4)),
                                  child: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dynamic Body Content
                        Flexible(fit: FlexFit.loose, child: widget.body),

                        // Footer Buttons
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomOCTAButton(
                                icon: widget.refreshTitle == 'Refresh' ? Icons.refresh : Icons.clear_all,
                                title: widget.refreshTitle,
                                action: () {
                                  if (widget.onRefresh != null) {
                                    widget.onRefresh!();
                                  }
                                },
                              ),
                              CustomECTAButton(
                                title: 'Submit',
                                action: () {
                                  // Collect filter values from the body
                                  Map<String, dynamic> filterValues = {};

                                  if (widget.onSubmitted != null) {
                                    widget.onSubmitted!(filterValues);
                                  }
                                  _toggleOverlay();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        key: _buttonKey,
        onTap: _toggleOverlay,
        child: Container(
          width: widget.width,
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
                  widget.title,
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

// Updated OverlayTFT with sign parameter
class OverlayTFT extends StatelessWidget {
  const OverlayTFT({
    super.key,
    required this.controller,
    required this.title,
    this.enabled = true,
    this.keyboardType,
    this.sign, // Optional sign parameter
  });
  final String title;
  final TextEditingController? controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? sign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: HighlightText(title, style: TextStyle(fontSize: 14, color: enabled ? Colors.black : Colors.grey)),
          ),
          SizedBox(
            height: 30,
            width: sign != null ? 140 : 184, // Adjust width if sign is present
            child: TextFormField(
              controller: controller,
              enabled: enabled, // Disable/enable based on switch
              keyboardType: keyboardType,

              decoration: tfInputDecoration.copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                filled: !enabled,
                fillColor: !enabled ? Colors.grey.shade100 : null,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (sign != null) ...[const SizedBox(width: 4), HighlightText(sign!, style: TextStyle(fontSize: 14, color: enabled ? Colors.black : Colors.grey))],
        ],
      ),
    );
  }
}
