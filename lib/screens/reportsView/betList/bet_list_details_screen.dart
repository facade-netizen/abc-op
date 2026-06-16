import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_betlist_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_order_event_bloc.dart';
import '../../../model/bet_list_model.dart';
import '../../../model/bet_status_option.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../filterOverlay/download_report.dart';
import '../../filterOverlay/events_filter_overlay.dart';
import '../../logView/agencyLogHistory/balance_log_screen.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';

class BetListDetailsScreen extends StatefulWidget {
  const BetListDetailsScreen({super.key});

  @override
  State<BetListDetailsScreen> createState() => _BetListDetailsScreenState();
}

class _BetListDetailsScreenState extends State<BetListDetailsScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController betIdController = TextEditingController();

  String selectedSport = 'Cricket';

  // Filter values
  Map<String, dynamic> selectedEvents = {};
  String selectedStatus = 'Unmatched';
  List<String> get statuses => betListDetailsStatuses.map((option) => option.label).toList();
  // Helper to build bet status params from the current status selection
  Map<String, dynamic> getStatusParams() {
    final selected = betListDetailsStatuses.firstWhere((option) => option.label == selectedStatus, orElse: () => betListDetailsStatuses.first);
    return {'isDone': selected.isDone, 'status': selected.status};
  }

  Map<String, dynamic> betListDetailsSP = {'Soccer': 1, 'Tennis': 2, 'Cricket': 4, 'Basketball': 00};

  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<BetData>> _pageCache = {};

  @override
  void initState() {
    super.initState();
    context.read<FetchBetListBloc>().add(FetchBetListInt());
  }

  // Helper function to fetch bet list with proper status handling
  void fetchBetList({required String fromDate, required String toDate, int page = 1}) {
    if (page == 1) {
      _pageCache.clear();
    }

    final int safePage = page < 1 ? 1 : page;

    final statusData = getStatusParams();
    if (statusData['isDone'] == null || statusData['status'] == null) {
      context.read<FetchBetListBloc>().add(FetchBetListInt());
      return;
    }

    int getSelectedSportId() {
      return betListDetailsSP[selectedSport] ?? 4;
    }

    ///selected events and markets
    final String? eventIds = joinIds(selectedEvents['eventIds']);
    final String? marketIds = joinIds(selectedEvents['marketIds']);

    currentPage = safePage;

    context.read<FetchBetListBloc>().add(
      FetchBetList(
        fromDate: fromDate,
        toDate: toDate,
        sid: getSelectedSportId(),
        isDone: statusData['isDone'] as bool?,
        status: statusData['status'] as String?,
        page: safePage,
        limit: 10,
        betIds: betIdController.text.isNotEmpty ? betIdController.text : null,
        userId: userIdController.text.isNotEmpty ? userIdController.text : null,
        eventIds: eventIds,
        marketIds: marketIds,
        bettingType: 0,
      ),
    );
    context.read<FetchOrderEventsBloc>().add(
      FetchOrderEvents(
        fromDate: fromDate,
        toDate: toDate,
        sid: getSelectedSportId(),
        isDone: statusData['isDone'] as bool?,
        status: statusData['status'] as String?,
        page: safePage,
        limit: 10,
        betIds: betIdController.text.isNotEmpty ? betIdController.text : null,
        userId: userIdController.text.isNotEmpty ? userIdController.text : null,
        eventIds: eventIds,
        marketIds: marketIds,
        bettingType: 0,
      ),
    );
  }

  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    if (totalPages != 0 && safePage > totalPages) return;
    fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text, page: safePage);
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
              const RiskHeader(type: 1, title: "Bet List Details"),

              /// Sport filters
              Row(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: betListDetailsSP.keys.map((sport) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(value: sport, groupValue: selectedSport, onChanged: (value) => setState(() => selectedSport = value!)),
                          HighlightText(sport, style: const TextStyle(fontSize: 13)),
                        ],
                      );
                    }).toList(),
                  ),
                  wb10,
                  EventsFilterOverlayNew(
                    width: 200,
                    onSubmitted: (events) {
                      setState(() {
                        selectedEvents = events;
                      });
                      fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text);
                    },
                  ),
                ],
              ),
              hb8,

              /// Status, date & inplay filters
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        RowDropdown<String>(
                          title: 'Bet Status',
                          value: selectedStatus,
                          items: statuses,
                          onChanged: (value) {
                            if (value != null) setState(() => selectedStatus = value);
                          },
                        ),
                        PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
                      ],
                    ),
                    hb10,
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        RowTFF(title: 'Player Id', controller: userIdController, hintText: "enter playerId..."),
                        RowTFF(title: 'Bet Id', controller: betIdController, hintText: "enter betId..."),
                      ],
                    ),
                    hb20,

                    /// Action buttons
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
                            fetchBetList(fromDate: now.toIso8601String(), toDate: now.toIso8601String());
                          },
                        ),
                        CustomECTAButton(
                          title: 'Get History',
                          action: () {
                            validateAndSwapDates(fromDateController, toDateController);
                            fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text, page: 1);
                          },
                        ),
                        BlocBuilder<FetchBetListBloc, FetchBetListState>(
                          builder: (context, fbl) {
                            List<BetData> betsListForTable = [];
                            if (fbl is FetchBetListSuccess) {
                              betsListForTable = fbl.betsList;
                            }
                            return DownloadReport(
                              height: 30,
                              reportName: 'Bet List Details',
                              headerTitles: betDataColumns.map((e) => e.label).toList(),
                              rowData: betsListForTable.map((row) {
                                return betDataColumns.map((col) {
                                  if (col.label == 'Market') {
                                    return "${row.sport} > ${row.event} > ${row.marketName}";
                                  }
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
                    hb20,
                  ],
                ),
              ),

              /// Table
              BlocBuilder<FetchBetListBloc, FetchBetListState>(
                builder: (context, fbl) {
                  List<BetData> betsList = [];

                  if (fbl is FetchBetListSuccess) {
                    totalPages = fbl.response.totalPages;
                    _pageCache[fbl.response.page] = fbl.betsList;
                    betsList = _pageCache[currentPage] ?? [];
                  }

                  return fbl is FetchBetListProgress
                      ? LoaderContainerWithMessage(message: "Loading...")
                      : betsList.isEmpty
                      ? SizedBox.shrink()
                      : CustomPaginatedTable<BetData>(
                          columns: betDataColumns,
                          data: betsList,
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
            ],
          ),
        ),
      ),
    );
  }
}
