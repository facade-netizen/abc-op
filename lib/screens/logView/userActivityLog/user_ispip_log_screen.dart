import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_all_wl_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_user_ispip_logs_bloc.dart';
import '../../../model/ispip_log_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/date_filter_type.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../filterOverlay/download_report.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import '../agencyLogHistory/balance_log_screen.dart';

class UserIspipLogScreen extends StatefulWidget {
  const UserIspipLogScreen({super.key, required this.title});
  final String title;
  @override
  State<UserIspipLogScreen> createState() => _UserIspipLogScreenState();
}

class _UserIspipLogScreenState extends State<UserIspipLogScreen> {
  final TextEditingController ispController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  /// USER LEVEL
  final Map<String, String> userLevelMap = {"All": "", "Senior Super": "supersuperAdmin", "Super": "superAdmin", "Master Agent": "master", "Player": "client"};
  List<String> sites = ["All"];
  String selectedUserLevel = "All";
  String selectedSite = "All";

  ///Pagination variables
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<IspIpLogsData>> _pageCache = <int, List<IspIpLogsData>>{};

  DateTime get now => DateTime.now();

  void fetchActivityLogs({DateTime? fromDate, DateTime? toDate, int page = 1}) {
    if (ispController.text.isEmpty && ipController.text.isEmpty) {
      showSnackBar(context, "ISP / IP is needed", error: true);
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
    Map<String, dynamic> body = {
      "role": userLevelMap[selectedUserLevel],
      "wlName": selectedSite == "All" ? "" : selectedSite,
      "isp": ispController.text.trim(),
      "ip": ipController.text.trim(),
      "from": from,
      "to": to,
      "page": currentPage,
      "limit": 20,
    };
    context.read<FetchUserIspIpLogsBloc>().add(FetchUserIspIpLogs(body: body));
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

  Widget buildQuickFilterButton(String title, DateFilterType type) {
    return CustomOCTAButton(
      title: title,
      action: () {
        final range = getDateRange(type);
        fromDateController.text = range.from.toIso8601String().split('T').first;
        toDateController.text = range.to.toIso8601String().split('T').first;
        currentPage = 1;
        fetchActivityLogs(fromDate: range.from, toDate: range.to, page: 1);
      },
    );
  }

  @override
  void dispose() {
    ispController.dispose();
    ipController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<FetchAllWlBloc, FetchAllWlState>(
          builder: (context, wls) {
            if (wls is FetchAllWlSuccess) {
              sites = ["All", ...wls.wlList];
            }
            return RowDropdown<String>(
              title: 'Site',
              value: selectedSite,
              items: sites,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedSite = value);
                }
              },
            );
          },
        ),
        hb10,

        /// FILTERS
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            /// ISP
            RowTFF(width: 300, title: 'ISP', controller: ispController, hintText: "enter isp..."),

            /// IP Address
            RowTFF(width: 300, title: 'IP', controller: ipController, hintText: "enter ip..."),
            RowDropdown<String>(
              title: 'User Type',
              value: selectedUserLevel,
              items: userLevelMap.keys.toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedUserLevel = value);
                }
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
                  buildQuickFilterButton('Just For Today', DateFilterType.today),
                  buildQuickFilterButton('From Yesterday', DateFilterType.yesterday),
                  buildQuickFilterButton('Last 7 days', DateFilterType.last7Days),
                  buildQuickFilterButton('Last 30 days', DateFilterType.last30Days),
                  buildQuickFilterButton('Last 2 Months', DateFilterType.last2Months),
                  CustomECTAButton(
                    title: 'Get P & L',
                    action: () {
                      currentPage = 1; // Reset to first page
                      fetchActivityLogs(page: 1);
                    },
                  ),
                  BlocBuilder<FetchUserIspIpLogsBloc, FetchUserIspIpLogsState>(
                    builder: (context, als) {
                      List<IspIpLogsData> ispIpLogs = [];
                      if (als is FetchUserIspIpLogsSuccess) {
                        ispIpLogs = als.ispIpLogsResponse.data;
                      }
                      return DownloadReport(
                        reportName: widget.title,
                        headerTitles: ispIpLogColumns.map((e) => e.label).toList(),
                        rowData: ispIpLogs.map((row) {
                          return ispIpLogColumns.map((col) {
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

        BlocBuilder<FetchUserIspIpLogsBloc, FetchUserIspIpLogsState>(
          builder: (context, als) {
            if (als is FetchUserIspIpLogsSuccess) {
              totalPages = als.ispIpLogsResponse.totalPages;
              _pageCache[als.ispIpLogsResponse.page] = als.ispIpLogsResponse.data;
            }
            final List<IspIpLogsData> ispIpLogs = _pageCache[currentPage] ?? [];

            return als is FetchUserIspIpLogsProgress
                ? LoaderContainerWithMessage()
                : CustomPaginatedTable<IspIpLogsData>(
                    topPadding: 0,
                    data: ispIpLogs,
                    columns: ispIpLogColumns,
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
