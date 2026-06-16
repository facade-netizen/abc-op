import 'package:flutter/material.dart';

import '../../reusable/button.dart';
import '../../reusable/colors.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/sized_box_hw.dart';
import '../../reusable/style.dart';
import '../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../riskView/riskMonitoring/row_dropdown.dart';

class CalculateExposureScreen extends StatefulWidget {
  const CalculateExposureScreen({super.key});

  @override
  State<CalculateExposureScreen> createState() => _CalculateExposureScreenState();
}

class _CalculateExposureScreenState extends State<CalculateExposureScreen> {
  List<String> sideList = ['Back', 'Lay'];
  List<String> isMatchedList = ['Yes', 'No'];
  String selectedSide = 'Back';
  String selectedIsmatched = 'Yes';

  // Controllers for text fields
  final TextEditingController eventIdController = TextEditingController();
  final TextEditingController marketIdController = TextEditingController();
  final TextEditingController numberOfWinnerController = TextEditingController();
  final TextEditingController numberOfActiveRunnerController = TextEditingController();
  final TextEditingController sectionIdController = TextEditingController();
  final TextEditingController oddsController = TextEditingController();
  final TextEditingController stakeController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    eventIdController.dispose();
    marketIdController.dispose();
    numberOfWinnerController.dispose();
    numberOfActiveRunnerController.dispose();
    sectionIdController.dispose();
    oddsController.dispose();
    stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hb10,
              RiskHeader(
                type: 1,
                title: "Calculate Exposure",
              ),
              Container(
                decoration: BoxDecoration(
                  color: accountStatementHeaderBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        CalculateExposureTFF(
                          title: 'eventId',
                          controller: eventIdController,
                        ),
                        CalculateExposureTFF(
                          title: 'marketId',
                          controller: marketIdController,
                        ),
                        CalculateExposureTFF(
                          title: 'number of winner',
                          controller: numberOfWinnerController,
                        ),
                        CalculateExposureTFF(
                          title: 'number of active runner',
                          controller: numberOfActiveRunnerController,
                        ),
                      ],
                    ),
                    hb12,
                    Row(
                      spacing: 10,
                      children: [
                        HighlightText(
                          "betting data",
                          style: TextStyle(color: black, fontWeight: FontWeight.w600),
                        ),
                        CustomECTAButton(
                          title: 'JSON format',
                          action: () {
                            // Handle JSON format
                          },
                        ),
                        CustomECTAButton(
                          title: 'Add',
                          action: () {
                            // Handle Add
                          },
                        ),
                      ],
                    ),
                    hb10,
                    Row(
                      spacing: 10,
                      children: [
                        CalculateExposureTFF(
                          title: 'sectionId',
                          controller: sectionIdController,
                        ),
                        RowDropdown<String>(
                          title: 'Side',
                          value: selectedSide,
                          items: sideList,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSide = value;
                              });
                            }
                          },
                        ),
                        CalculateExposureTFF(
                          title: 'odds',
                          controller: oddsController,
                          width: 100,
                        ),
                        CalculateExposureTFF(
                          title: 'stake',
                          controller: stakeController,
                          width: 120,
                        ),
                        RowDropdown<String>(
                          title: 'isMatched',
                          value: selectedIsmatched,
                          items: isMatchedList,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedIsmatched = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    hb10,
                    CustomECTAButton(
                      title: 'Submit',
                      fontSize: 12,
                      action: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalculateExposureTFF extends StatelessWidget {
  const CalculateExposureTFF({
    super.key,
    required this.title,
    this.width,
    this.controller,
  });
  final String title;
  final double? width;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HighlightText(
          "$title : ",
          style: TextStyle(color: black),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 25,
          width: width ?? 200,
          child: TextField(
            style: const TextStyle(fontSize: 11),
            controller: controller,
            decoration: tfInputDecoration.copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
          ),
        ),
      ],
    );
  }
}
