import 'package:flutter/material.dart';

import 'filter_overlay_button.dart';

class OddsDifferentialFilterOverlay extends StatefulWidget {
  final double width;
  final Function(Map<String, dynamic> filterValues)? onSubmitted;

  const OddsDifferentialFilterOverlay({super.key, required this.width, this.onSubmitted});

  @override
  State<OddsDifferentialFilterOverlay> createState() => _OddsDifferentialFilterOverlayState();
}

class _OddsDifferentialFilterOverlayState extends State<OddsDifferentialFilterOverlay> {
  bool status = true;
  late TextEditingController backGreaterController;
  late TextEditingController backLowerController;
  late TextEditingController layGreaterController;
  late TextEditingController layLowerController;

  // Store the setBodyState function
  late void Function(void Function()) _setBodyState;

  @override
  void initState() {
    super.initState();
    backGreaterController = TextEditingController();
    backLowerController = TextEditingController();
    layGreaterController = TextEditingController();
    layLowerController = TextEditingController();
  }

  @override
  void dispose() {
    backGreaterController.dispose();
    backLowerController.dispose();
    layGreaterController.dispose();
    layLowerController.dispose();
    super.dispose();
  }

  void _refreshFilters() {
    // Update both the local state and the body state
    _setBodyState(() {
      status = false;
      backGreaterController.clear();
      backLowerController.clear();
      layGreaterController.clear();
      layLowerController.clear();
    });

    // Also update the widget state
    setState(() {
      status = false;
      backGreaterController.clear();
      backLowerController.clear();
      layGreaterController.clear();
      layLowerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterOverlay(
      width: widget.width,
      title: 'Odds Differential Filter (%)',
      refreshTitle: 'Clear All',
      onRefresh: _refreshFilters,
      onSubmitted: (filterValues) {
        Map<String, dynamic> values = {};

        values.addAll({
          'backGreater': backGreaterController.text,
          'backLower': backLowerController.text,
          'layGreater': layGreaterController.text,
          'layLower': layLowerController.text,
        });

        if (widget.onSubmitted != null) {
          widget.onSubmitted!(values);
        }
      },
      body: StatefulBuilder(
        builder: (context, setBodyState) {
          // Store the setBodyState function for later use
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setBodyState = setBodyState;
          });

          return Container(
            height: 185,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Back Greater Than or Equal
                OverlayTFT(title: 'Back >=', controller: backGreaterController, sign: " %", enabled: status),

                // Back Less Than or Equal
                OverlayTFT(title: 'Back <=', controller: backLowerController, sign: " %", enabled: status),

                // Lay Greater Than or Equal
                OverlayTFT(title: 'Lay >=', controller: layGreaterController, sign: " %", enabled: status),

                // Lay Less Than or Equal
                OverlayTFT(title: 'Lay <=', controller: layLowerController, sign: " %", enabled: status),
              ],
            ),
          );
        },
      ),
    );
  }
}
