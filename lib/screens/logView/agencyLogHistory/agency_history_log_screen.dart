import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_user_logs_bloc.dart';
import '../../../model/user_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/normal_pagination_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../filterOverlay/download_report.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import 'balance_log_screen.dart';

class AgencyHistoryLogScreen extends StatefulWidget {
  const AgencyHistoryLogScreen({super.key});

  @override
  State<AgencyHistoryLogScreen> createState() => _AgencyHistoryLogScreenState();
}

class _AgencyHistoryLogScreenState extends State<AgencyHistoryLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController updaterIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  DateTime get now => DateTime.now();

  /// FETCH LOGS
  void fetchLogs({DateTime? fromDate, DateTime? toDate}) {
    validateAndSwapDates(fromDateController, toDateController);
    final from = stringDateToDateTimeString(fromDate?.toString() ?? fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDate?.toString() ?? toDateController.text);

    context.read<FetchUserLogsBloc>().add(FetchUserLogs(userId: userIdController.text, updater: updaterIdController.text, from: from, to: to));
  }

  /// QUICK FILTER BUTTON
  Widget buildQuickFilterButton(String title, DateTime fromDate) {
    return CustomOCTAButton(
      title: title,
      action: () {
        fromDateController.text = fromDate.toIso8601String().split('T').first;
        fetchLogs(fromDate: fromDate, toDate: now);
      },
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    updaterIdController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "Agency History"),

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
                    hb10,

                    /// USER ID
                    Row(
                      children: [
                        RowTFF(title: 'User Id', controller: userIdController, hintText: "enter userId...", width: 300),
                        wb10,
                        const HighlightText('ex: account123, account456...'),
                      ],
                    ),

                    hb10,

                    /// UPDATER
                    RowTFF(title: 'Updater', controller: updaterIdController, hintText: "enter updaterId..."),
                    hb10,

                    /// DATE FILTER
                    PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),

                    hb10,

                    /// QUICK FILTERS + DOWNLOAD
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        buildQuickFilterButton('Just For Today', DateTime(now.year, now.month, now.day)),
                        buildQuickFilterButton('From Yesterday', now.subtract(const Duration(days: 1))),
                        buildQuickFilterButton('Last 7 days', now.subtract(const Duration(days: 7))),
                        buildQuickFilterButton('Last 30 days', now.subtract(const Duration(days: 30))),
                        buildQuickFilterButton('Last 2 Months', now.subtract(const Duration(days: 60))),

                        /// SEARCH
                        CustomECTAButton(title: 'Get P & L', action: fetchLogs),

                        /// DOWNLOAD
                        BlocBuilder<FetchUserLogsBloc, FetchUserLogsState>(
                          builder: (context, state) {
                            List<UserLogModel> logs = [];
                            if (state is FetchUserLogsSuccess) {
                              logs = state.userLogs;
                            }
                            return DownloadReport(
                              reportName: "Agency History",
                              headerTitles: agencyHistoryColumns.map((e) => e.label).toList(),
                              rowData: logs.map((row) {
                                return agencyHistoryColumns.map((col) {
                                  if (col.value != null) {
                                    return col.value!(row);
                                  }
                                  return '';
                                }).toList();
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),

                    hb10,
                  ],
                ),
              ),

              hb10,

              /// TABLE
              BlocBuilder<FetchUserLogsBloc, FetchUserLogsState>(
                builder: (context, state) {
                  List<UserLogModel> userLogs = [];
                  if (state is FetchUserLogsSuccess) {
                    userLogs = state.userLogs;
                  }
                  if (state is FetchUserLogsProgress) {
                    return const LoaderContainerWithMessage(message: "Loading...");
                  }
                  return NormalPaginationTable<UserLogModel>(
                    key: Key('agency_history_table_at_${DateTime.now().toIso8601String()}'),
                    data: userLogs,
                    pageSize: 25,
                    columns: agencyHistoryColumns,
                  );
                },
              ),
              hb12,
            ],
          ),
        ),
      ),
    );
  }
}
