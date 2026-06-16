import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../../model/activity_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../filterOverlay/download_report.dart';
import '../agencyLogHistory/balance_log_screen.dart';

class UserActivityLogScreen extends StatefulWidget {
  const UserActivityLogScreen({super.key, required this.title});
  final String title;
  @override
  State<UserActivityLogScreen> createState() => _UserActivityLogScreenState();
}

class _UserActivityLogScreenState extends State<UserActivityLogScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Pagination variables
  int currentPage = 1;
  int totalPages = 1;
  final int limit = 25;
  final Map<int, List<ActivityLogsData>> _pageCache = <int, List<ActivityLogsData>>{};

  DateTime get now => DateTime.now();

  void fetchActivityLogs({DateTime? fromDate, DateTime? toDate, int page = 1}) {
    if (userIdController.text.isEmpty) {
      showSnackBar(context, "Please select user from above", error: true);
      return;
    }
    validateAndSwapDates(fromDateController, toDateController);
    final from = stringDateToDateTimeString(fromDate?.toString() ?? fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDate?.toString() ?? toDateController.text);

    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
    }

    currentPage = page;

    context.read<FetchUserActivityLogsBloc>().add(FetchUserActivityLogs(userId: userIdController.text, from: from, to: to, page: currentPage, limit: limit));
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    if (safePage > totalPages && totalPages != 0) return;
    currentPage = safePage;
    fetchActivityLogs(page: safePage);
  }

  Widget buildQuickFilterButton(String title, DateTime fromDate) {
    return CustomOCTAButton(
      title: title,
      action: () {
        fromDateController.text = fromDate.toIso8601String().split('T').first;
        currentPage = 1; // Reset to first page
        fetchActivityLogs(fromDate: fromDate, toDate: now, page: 1);
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
                fetchActivityLogs(page: 1);
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
                  buildQuickFilterButton('Just For Today', DateTime(now.year, now.month, now.day)),
                  buildQuickFilterButton('From Yesterday', now.subtract(const Duration(days: 1))),
                  buildQuickFilterButton('Last 7 days', now.subtract(const Duration(days: 7))),
                  buildQuickFilterButton('Last 30 days', now.subtract(const Duration(days: 30))),
                  buildQuickFilterButton('Last 2 Months', now.subtract(const Duration(days: 60))),
                  CustomECTAButton(
                    title: 'Get P & L',
                    action: () {
                      currentPage = 1; // Reset to first page
                      fetchActivityLogs(page: 1);
                    },
                  ),
                  BlocBuilder<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
                    builder: (context, als) {
                      List<ActivityLogsData> activityLogs = [];
                      if (als is FetchUserActivityLogsSuccess) {
                        activityLogs = als.activityLogsResponse.data;
                      }
                      return DownloadReport(
                        reportName: widget.title,
                        headerTitles: activityLogColumns.map((e) => e.label).toList(),
                        rowData: activityLogs.map((row) {
                          return activityLogColumns.map((col) {
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

        BlocBuilder<FetchUserActivityLogsBloc, FetchUserActivityLogsState>(
          builder: (context, als) {
            if (als is FetchUserActivityLogsProgress) {
              return LoaderContainerWithMessage();
            }

            if (als is FetchUserActivityLogsSuccess) {
              totalPages = als.activityLogsResponse.totalPages;
              _pageCache[als.activityLogsResponse.page] = als.activityLogsResponse.data;
            }

            final List<ActivityLogsData> activityLogs = _pageCache[currentPage] ?? [];

            return CustomPaginatedTable<ActivityLogsData>(
              topPadding: 5,
              data: activityLogs,
              columns: activityLogColumns,
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
