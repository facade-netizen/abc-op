import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_change_pass_logs_bloc.dart';
import '../../../model/change_pass_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/date_filter_type.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../filterOverlay/download_report.dart';
import '../agencyLogHistory/balance_log_screen.dart';

class ChangePasswordLogScreen extends StatefulWidget {
  const ChangePasswordLogScreen({super.key, required this.title});
  final String title;
  @override
  State<ChangePasswordLogScreen> createState() => _ChangePasswordLogScreenState();
}

class _ChangePasswordLogScreenState extends State<ChangePasswordLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Pagination variables
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<ChangePassLogsData>> _pageCache = <int, List<ChangePassLogsData>>{};

  DateTime get now => DateTime.now();
  DateTime get yesterday => now.subtract(const Duration(days: 1));

  void fetchChangePasswordLogs({DateTime? fromDate, DateTime? toDate, int page = 1}) {
    if (userIdController.text.isEmpty) {
      showSnackBar(context, "Please select user from above", error: true);
      return;
    }
    validateAndSwapDates(fromDateController, toDateController);
    final from = fromToDateTimeString(fromDate?.toString() ?? fromDateController.text, startOfDay: true);
    final to = fromToDateTimeString(toDate?.toString() ?? toDateController.text, startOfDay: false);

    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
    }

    currentPage = page;
    Map<String, dynamic> requestBody = {"userName": userIdController.text, "from": from, "to": to, "page": currentPage, "limit": 20};
    context.read<FetchChangePassLogsBloc>().add(FetchChangePassLogs(body: requestBody));
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    if (safePage > totalPages && totalPages != 0) return;
    currentPage = safePage;
    fetchChangePasswordLogs(page: safePage);
  }

  Widget buildQuickFilterButton(String title, DateFilterType type) {
    return CustomOCTAButton(
      title: title,
      action: () {
        final range = getDateRange(type);
        fromDateController.text = range.from.toIso8601String().split('T').first;
        toDateController.text = range.to.toIso8601String().split('T').first;
        currentPage = 1;
        fetchChangePasswordLogs(fromDate: range.from, toDate: range.to, page: 1);
      },
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// User ID + Search
        Row(
          children: [
            RowTFF(title: 'User Id', controller: userIdController, hintText: "enter userId...", width: 200),
            wb10,
            CustomECTAButton(
              title: 'Search',
              action: () {
                currentPage = 1; // Reset to first page on new search
                fetchChangePasswordLogs(page: 1);
              },
            ),
          ],
        ),
        hb10,

        /// Filter Section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: accountStatementHeaderBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hb10,
              PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      buildQuickFilterButton('Just For Today', DateFilterType.today),
                      buildQuickFilterButton('From Yesterday', DateFilterType.yesterday),
                      buildQuickFilterButton('Last 7 days', DateFilterType.last7Days),
                      buildQuickFilterButton('Last 30 days', DateFilterType.last30Days),
                      buildQuickFilterButton('Last 2 Months', DateFilterType.last2Months),
                    ],
                  ),
                  CustomECTAButton(
                    title: 'Get P & L',
                    action: () {
                      currentPage = 1; // Reset to first page
                      fetchChangePasswordLogs(page: 1);
                    },
                  ),
                  BlocBuilder<FetchChangePassLogsBloc, FetchChangePassLogsState>(
                    builder: (context, als) {
                      List<ChangePassLogsData> changePassLogs = [];
                      if (als is FetchChangePassLogsSuccess) {
                        changePassLogs = als.changePass.data;
                      }
                      return DownloadReport(
                        reportName: widget.title,
                        headerTitles: changePassLogColumns.map((e) => e.label).toList(),
                        rowData: changePassLogs.map((row) {
                          return changePassLogColumns.map((col) {
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

        /// Selected Table
        SizedBox(
          height: 40,
          child: Row(
            children: [
              HighlightText(
                widget.title,
                style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        BlocBuilder<FetchChangePassLogsBloc, FetchChangePassLogsState>(
          builder: (context, als) {
            if (als is FetchChangePassLogsProgress) {
              return LoaderContainerWithMessage();
            }

            if (als is FetchChangePassLogsSuccess) {
              totalPages = als.changePass.totalPages;
              _pageCache[als.changePass.page] = als.changePass.data;
            }

            final List<ChangePassLogsData> changePassLogs = _pageCache[currentPage] ?? [];

            return CustomPaginatedTable<ChangePassLogsData>(
              topPadding: 5,
              data: changePassLogs,
              columns: changePassLogColumns,
              currentPage: currentPage,
              totalPages: totalPages,
              onPageTap: fetchPage,
              onPrevious: () {
                if (currentPage <= 1) return;
                fetchPage(currentPage - 1);
              },
              onNext: () {
                if (currentPage >= totalPages) return;
                fetchPage(currentPage + 1);
              },
            );
          },
        ),
        hb12,
      ],
    );
  }
}
