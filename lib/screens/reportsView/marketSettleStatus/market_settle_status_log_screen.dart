import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_settle_history_bloc.dart';
import '../../../model/settle_history_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/normal_pagination_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../filterOverlay/download_report.dart';
import '../../logView/agencyLogHistory/balance_log_screen.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';

class MarketSettleStatusLogScreen extends StatefulWidget {
  const MarketSettleStatusLogScreen({super.key});

  @override
  State<MarketSettleStatusLogScreen> createState() => _MarketSettleStatusLogScreenState();
}

class _MarketSettleStatusLogScreenState extends State<MarketSettleStatusLogScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController eventIdController = TextEditingController();
  final TextEditingController marketIdController = TextEditingController();

  /// Fetch helper
  void _fetchSettleHistory({required String from, required String to}) {
    final eventIdText = eventIdController.text.trim();
    if (eventIdText.isEmpty) {
      showSnackBar(context, "Event Id is required", error: true);
      return;
    }
    String? marketId = marketIdController.text.trim().isEmpty ? null : marketIdController.text;
    context.read<FetchSettleHistoryBloc>().add(FetchSettleHistory(eventId: eventIdText, marketId: marketId, fromDate: from, toDate: to));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "Market Settle Status Log"),

              /// FILTER SECTION
              Container(
                decoration: BoxDecoration(
                  color: accountStatementHeaderBg,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        /// EVENT ID
                        Row(
                          children: [
                            HighlightText('*', style: TextStyle(color: red)),
                            RowTFF(title: 'Event Id', controller: eventIdController, hintText: "Enter eventId..."),
                          ],
                        ),

                        wb10,

                        /// MARKET ID
                        RowTFF(title: 'Market Id', controller: marketIdController, hintText: "Enter marketId..."),
                      ],
                    ),

                    hb10,

                    /// DATE FILTER
                    PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),

                    hb20,

                    /// ACTION BUTTONS
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        CustomOCTAButton(
                          title: 'Just For Today',
                          action: () {
                            final now = DateTime.now();
                            final dateText = now.toIso8601String().split('T').first;
                            fromDateController.text = dateText;
                            toDateController.text = dateText;
                            final from = fromToDateTimeString(now.toIso8601String(), startOfDay: true);
                            final to = fromToDateTimeString(now.toIso8601String(), startOfDay: false);
                            _fetchSettleHistory(from: from, to: to);
                          },
                        ),

                        CustomECTAButton(
                          title: 'Get History',
                          action: () {
                            validateAndSwapDates(fromDateController, toDateController);
                            final from = fromToDateTimeString(fromDateController.text, startOfDay: true);
                            final to = fromToDateTimeString(toDateController.text, startOfDay: false);
                            _fetchSettleHistory(from: from, to: to);
                          },
                        ),

                        /// DOWNLOAD
                        BlocBuilder<FetchSettleHistoryBloc, FetchSettleHistoryState>(
                          builder: (context, shs) {
                            List<SettleHistoryData> settleHistory = [];

                            if (shs is FetchSettleHistorySuccess) {
                              settleHistory = shs.settleHistory;
                            }

                            return DownloadReport(
                              height: 30,
                              reportName: 'Market Settle Status Log',
                              headerTitles: marketSettleColumns.map((e) => e.label).toList(),
                              rowData: settleHistory.map((row) {
                                return marketSettleColumns.map((col) {
                                  if (col.value != null) {
                                    return col.value!(row);
                                  } else if (col.customCell != null) {
                                    return '';
                                  }
                                  return '';
                                }).toList();
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),

                    hb20,
                  ],
                ),
              ),

              hb10,

              /// TABLE
              BlocBuilder<FetchSettleHistoryBloc, FetchSettleHistoryState>(
                builder: (context, shs) {
                  List<SettleHistoryData> settleHistory = [];
                  if (shs is FetchSettleHistorySuccess) {
                    settleHistory = shs.settleHistory;
                  }

                  return shs is FetchSettleHistoryProgress
                      ? const LoaderContainerWithMessage(message: "Loading...")
                      : settleHistory.isEmpty
                      ? SizedBox()
                      : NormalPaginationTable<SettleHistoryData>(
                          pageSize: 12,
                          key: Key('settle_history_log_table_at_${DateTime.now().toIso8601String()}'),
                          data: settleHistory,
                          columns: marketSettleColumns,
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
