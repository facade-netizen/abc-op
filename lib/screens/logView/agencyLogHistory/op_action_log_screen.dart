import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_user_logs_bloc.dart';
import '../../../model/user_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/normal_pagination_table.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../filterOverlay/download_report.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import 'balance_log_screen.dart';

class OpActionLogScreen extends StatefulWidget {
  const OpActionLogScreen({super.key});

  @override
  State<OpActionLogScreen> createState() => _OpActionLogScreenState();
}

class _OpActionLogScreenState extends State<OpActionLogScreen> {
  final TextEditingController updaterIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  DateTime get now => DateTime.now();

  /// ACTION MAP
  final Map<String, int?> actionMap = {"All": null, "Status Change": 0, "Password Reset": 1, "Create Account": 2, "Update Credit": 3, "CreditRefUpdate": 4, "ChangePassword": 5};
  String selectedAction = "All";

  int? get selectedActionValue => actionMap[selectedAction];

  /// FETCH LOGS
  void fetchLogs({DateTime? fromDate, DateTime? toDate}) {
    validateAndSwapDates(fromDateController, toDateController);
    final from = stringDateToDateTimeString(fromDate?.toString() ?? fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDate?.toString() ?? toDateController.text);
    context.read<FetchUserLogsBloc>().add(FetchUserLogs(logType: selectedActionValue, updater: updaterIdController.text, from: from, to: to));
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
    updaterIdController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RiskHeader(type: 1, title: "OP Action Log"),

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

                    /// ACTION + OP
                    Row(
                      children: [
                        RowDropdown<String>(
                          width: 200,
                          title: 'Action',
                          value: selectedAction,
                          items: actionMap.keys.toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedAction = value;
                              });
                            }
                          },
                        ),
                        wb10,
                        RowTFF(title: 'OP', controller: updaterIdController, hintText: "enter updaterId...", width: 200),
                      ],
                    ),

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

                        /// DOWNLOAD REPORT
                        BlocBuilder<FetchUserLogsBloc, FetchUserLogsState>(
                          builder: (context, state) {
                            List<UserLogModel> logs = [];

                            if (state is FetchUserLogsSuccess) {
                              logs = state.userLogs;
                            }

                            return DownloadReport(
                              reportName: "OP Action Log",
                              headerTitles: opActionLogColumns.map((e) => e.label).toList(),
                              rowData: logs.map((row) {
                                return opActionLogColumns.map((col) {
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
                  List<UserLogModel> logs = [];

                  if (state is FetchUserLogsSuccess) {
                    logs = state.userLogs;
                  }
                  if (state is FetchUserLogsProgress) {
                    return const LoaderContainerWithMessage(message: "Loading...");
                  }

                  return NormalPaginationTable<UserLogModel>(
                    key: Key('op_action_log_table_at_${DateTime.now().toIso8601String()}'),
                    data: logs,
                    pageSize: 25,
                    columns: opActionLogColumns,
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
