import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../reusable/colors.dart';
import 'filter_overlay_button.dart';

class IPISPFilterOverlay extends StatefulWidget {
  final double width;
  final Function(Map<String, dynamic> filterValues)? onSubmitted;

  const IPISPFilterOverlay({
    super.key,
    required this.width,
    this.onSubmitted,
  });

  @override
  State<IPISPFilterOverlay> createState() => _IPISPFilterOverlayState();
}

class _IPISPFilterOverlayState extends State<IPISPFilterOverlay> {
  bool status = true;
  late TextEditingController ipController;
  late TextEditingController ispController;

  // Store the setBodyState function
  late void Function(void Function()) _setBodyState;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController();
    ispController = TextEditingController();
  }

  @override
  void dispose() {
    ipController.dispose();
    ispController.dispose();
    super.dispose();
  }

  void _refreshFilters() {
    // Update both the local state and the body state
    _setBodyState(() {
      status = false;
      ipController.clear();
      ispController.clear();
    });

    // Also update the widget state
    setState(() {
      status = false;
      ipController.clear();
      ispController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterOverlay(
      width: widget.width,
      title: 'IP/ISP Filter',
      refreshTitle: 'Clear All',
      onRefresh: _refreshFilters,
      onSubmitted: (filterValues) {
        Map<String, dynamic> values = {
          'switchStatus': status,
        };

        values.addAll({
          'ipValue': ipController.text,
          'ispValue': ispController.text,
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Switch Section
              Container(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 100),
                    FlutterSwitch(
                      width: 70.0,
                      height: 35.0,
                      valueFontSize: 12.0,
                      toggleSize: 20.0,
                      value: status,
                      borderRadius: 20.0,
                      padding: 6.0,
                      activeText: "ON",
                      activeColor: green,
                      inactiveColor: grey,
                      inactiveText: "OFF",
                      showOnOff: true,
                      onToggle: (val) {
                        setBodyState(() {
                          status = !status;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Input Fields Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                child: Column(
                  children: [
                    OverlayTFT(
                      title: 'IP',
                      controller: ipController,
                      enabled: status,
                    ),
                    OverlayTFT(
                      title: 'ISP',
                      controller: ispController,
                      enabled: status,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
