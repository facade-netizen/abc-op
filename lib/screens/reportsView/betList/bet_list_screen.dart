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
import '../../../reusable/string.dart';
import '../../filterOverlay/download_report.dart';
import '../../filterOverlay/events_filter_overlay.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../filterOverlay/ipisp_filter_overlay.dart';
import '../../filterOverlay/odds_differential_filter_overlay.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import '../../filterOverlay/user_filter_overlay.dart';

///Sport Config Model
class SportConfig {
  final int sid;
  final int bettingType;
  const SportConfig({required this.sid, required this.bettingType});
}

///Mapping
final Map<String, SportConfig> sportConfigMap = {
  'Soccer': SportConfig(sid: 1, bettingType: 0),
  'BOOK Soccer': SportConfig(sid: 1, bettingType: 2),
  'Sportsbook Soccer': SportConfig(sid: 1, bettingType: 00),
  'Tennis': SportConfig(sid: 2, bettingType: 0),
  'BOOK Tennis': SportConfig(sid: 2, bettingType: 2),
  'Sportsbook Tennis': SportConfig(sid: 2, bettingType: 00),
  'Cricket': SportConfig(sid: 4, bettingType: 0),
  'Cricket/Fancy Bet': SportConfig(sid: 4, bettingType: 1),
  'BOOK Cricket': SportConfig(sid: 4, bettingType: 2),
  'Sportsbook Cricket': SportConfig(sid: 4, bettingType: 00),
  'Horse Racing': SportConfig(sid: 7, bettingType: 0),
  'Election/Fancy Bet': SportConfig(sid: 2378961, bettingType: 0),
  'BOOK Election': SportConfig(sid: 2378961, bettingType: 2),
};

class BetListScreen extends StatefulWidget {
  const BetListScreen({super.key});

  @override
  State<BetListScreen> createState() => _BetListScreenState();
}

class _BetListScreenState extends State<BetListScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String selectedSport = 'Cricket';

  bool get isSportsBook => selectedSport.startsWith('Sportsbook');

  String selectedStatus = 'Unmatched';
  String selectedRowPerPage = '20';
  List<String> rowPerPage = ['All', '20', '50', '100'];

  List<BetStatusOption> get _currentStatusOptions {
    final config = getSelectedSportConfig();
    return config.bettingType == 0 ? exchangeStatuses : bookMakerStatuses;
  }

  List<String> get statuses => _currentStatusOptions.map((option) => option.label).toList();

  // Filter values
  Map<String, dynamic> selectedEvents = {};

  // Odds Differential filter values (Back/Lay %)
  Map<String, dynamic> oddsDifferentialValues = {};

  // User filter values
  Map<String, dynamic> userFilterValues = {};

  // IP/ISP filter values
  Map<String, dynamic> ipispFilterValues = {};

  int currentPage = 1;
  int totalPages = 1;
  bool _isSportsBookData = false;
  final Map<int, List<BetData>> _pageCache = {};

  @override
  void initState() {
    super.initState();
    context.read<FetchBetListBloc>().add(FetchBetListInt());
  }

  /// ✅ Get Config
  SportConfig getSelectedSportConfig() {
    return sportConfigMap[selectedSport] ?? const SportConfig(sid: 4, bettingType: 0);
  }

  void fetchBetList({required String fromDate, required String toDate, int page = 1}) {
    if (page == 1) {
      _pageCache.clear();
    }

    final int safePage = page < 1 ? 1 : page;
    final selectedStatusOption = _currentStatusOptions.firstWhere((option) => option.label == selectedStatus, orElse: () => _currentStatusOptions.first);

    final bool? isDone = selectedStatusOption.isDone;
    final String? statusParam = selectedStatusOption.status;
    if (isDone == null || statusParam == null) {
      context.read<FetchBetListBloc>().add(FetchBetListInt());
      return;
    }

    final config = getSelectedSportConfig();

    String? userId;
    if (userFilterValues['switchStatus'] == true) {
      userId = userFilterValues['userId'];
    }

    String? ip;
    String? isp;
    if (ipispFilterValues['switchStatus'] == true) {
      ip = ipispFilterValues['ipValue'];
      isp = ipispFilterValues['ispValue'];
    }

    int? limit;
    int? apiPage;

    if (selectedRowPerPage == "All") {
      limit = 0;
      apiPage = 0;
    } else {
      limit = int.tryParse(selectedRowPerPage);
      apiPage = safePage;
    }

    currentPage = safePage;

    ///odds differential filter values
    double? diffOdds;
    bool? oddsDiffGreater;
    String? side;
    if (oddsDifferentialValues['backGreater'] != null && oddsDifferentialValues['backGreater'].isNotEmpty) {
      oddsDiffGreater = true;
      diffOdds = double.tryParse(oddsDifferentialValues['backGreater']);
      side = 'back';
    }
    if (oddsDifferentialValues['backLower'] != null && oddsDifferentialValues['backLower'].isNotEmpty) {
      oddsDiffGreater = false;
      diffOdds = double.tryParse(oddsDifferentialValues['backLower']);
      side = 'back';
    }
    if (oddsDifferentialValues['layGreater'] != null && oddsDifferentialValues['layGreater'].isNotEmpty) {
      oddsDiffGreater = true;
      diffOdds = double.tryParse(oddsDifferentialValues['layGreater']);
      side = 'lay';
    }
    if (oddsDifferentialValues['layLower'] != null && oddsDifferentialValues['layLower'].isNotEmpty) {
      oddsDiffGreater = false;
      diffOdds = double.tryParse(oddsDifferentialValues['layLower']);
      side = 'lay';
    }

    ///selected events and markets
    final String? eventIds = joinIds(selectedEvents['eventIds']);
    final String? marketIds = joinIds(selectedEvents['marketIds']);

    currentPage = safePage;
    setState(() {
      _isSportsBookData = isSportsBook;
    });

    context.read<FetchBetListBloc>().add(
      FetchBetList(
        fromDate: fromDate,
        toDate: toDate,
        sid: config.sid,
        isDone: isDone,
        status: statusParam,
        page: apiPage,
        limit: limit,
        userId: userId,
        bettingType: config.bettingType,
        ip: ip,
        isp: isp,
        diffOdds: diffOdds,
        oddDiffGreater: oddsDiffGreater,
        side: side,
        eventIds: eventIds,
        marketIds: marketIds,
        sports: [selectedSport],
      ),
    );
    context.read<FetchOrderEventsBloc>().add(
      FetchOrderEvents(
        fromDate: fromDate,
        toDate: toDate,
        sid: config.sid,
        isDone: isDone,
        status: statusParam,
        bettingType: config.bettingType,
        // userId: userId,
        // ip: ip,
        // isp: isp,
        // eventIds: eventIds,
        // marketIds: marketIds,
        page: apiPage,
        limit: limit,
        sports: [selectedSport],
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
              const RiskHeader(type: 1, title: "Bet List"),

              /// Sport Filters
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: sportConfigMap.keys.map((sport) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: sport,
                        groupValue: selectedSport,
                        onChanged: (value) {
                          setState(() {
                            selectedSport = value!;
                            // reset status if not valid for new bettingType
                            if (!statuses.contains(selectedStatus)) {
                              selectedStatus = statuses.first;
                            }
                            if (selectedSport.startsWith('Sportsbook')) {
                              context.read<FetchOrderEventsBloc>().add(FetchOrderEventsInt());
                            }
                          });
                        },
                      ),
                      HighlightText(sport, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }).toList(),
              ),
              hb12,

              /// Filters
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  //if (!isSportsBook)
                  EventsFilterOverlayNew(
                    width: 130,
                    onSubmitted: (events) {
                      setState(() {
                        selectedEvents = events;
                      });
                      fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text);
                    },
                  ),
                  OddsDifferentialFilterOverlay(
                    width: 220,
                    onSubmitted: (values) {
                      setState(() {
                        oddsDifferentialValues = values;
                      });
                      fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text);
                    },
                  ),
                  UserFilterOverlay(
                    width: 150,
                    onSubmitted: (values) {
                      setState(() {
                        userFilterValues = values;
                      });
                      fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text);
                    },
                  ),

                  ///if (!isSportsBook)
                  IPISPFilterOverlay(
                    width: 150,
                    onSubmitted: (values) {
                      setState(() {
                        ipispFilterValues = values;
                      });
                      fetchBetList(fromDate: fromDateController.text, toDate: toDateController.text);
                    },
                  ),
                ],
              ),
              hb12,
              Row(
                children: [
                  RowDropdown<String>(
                    title: 'Show',
                    value: selectedRowPerPage,
                    items: rowPerPage,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRowPerPage = value);
                      }
                    },
                  ),
                  SizedBox(width: 5),
                  HighlightText('rows per page'),
                ],
              ),
              hb20,

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
                              reportName: 'Bet List',
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
                  ],
                ),
              ),
              BlocBuilder<FetchBetListBloc, FetchBetListState>(
                builder: (context, fbl) {
                  List<BetData> betsList = [];
                  if (fbl is FetchBetListSuccess) {
                    totalPages = fbl.response.totalPages;
                    _pageCache[fbl.response.page] = fbl.betsList;
                    betsList = _pageCache[currentPage] ?? [];
                  }

                  final bool showSportsbookColumns = _isSportsBookData && fbl is FetchBetListSuccess;
                  final bool showResult = betsList.any((bet) => bet.status.toLowerCase() == 'filled');
                  return fbl is FetchBetListProgress
                      ? const LoaderContainerWithMessage(message: "Loading...")
                      : betsList.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            hb30,
                            HighlightText(riskMonitoringDescription, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            hb10,
                            HighlightText(
                              betStatusNote,
                              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : CustomPaginatedTable<BetData>(
                          columns: showSportsbookColumns ? sbBetDataColumns(showResult: showResult) : betDataColumns,
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
