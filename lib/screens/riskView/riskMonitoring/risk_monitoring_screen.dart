import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_order_event_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_risk_monitoring_bloc.dart';
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
import '../../filterOverlay/bl_odds_differential_overlay.dart';
import '../../filterOverlay/download_report.dart';
import '../../filterOverlay/events_filter_overlay.dart';
import '../riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../filterOverlay/ipisp_filter_overlay.dart';
import '../../filterOverlay/odds_differential_filter_overlay.dart';
import '../../filterOverlay/back_lay_time_gap_filter_overlay.dart';
import 'row_dropdown.dart';
import '../../filterOverlay/stakes_filter_overlay.dart';
import '../../filterOverlay/user_filter_overlay.dart';

class RiskMonitoringScreen extends StatefulWidget {
  const RiskMonitoringScreen({super.key});

  @override
  State<RiskMonitoringScreen> createState() => _RiskMonitoringScreenState();
}

class _RiskMonitoringScreenState extends State<RiskMonitoringScreen> {
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  String selectedSport = 'Cricket';
  String selectedStatus = 'Unmatched';
  Map<String, dynamic> sportsListForRM = {'Soccer': 1, 'Tennis': 2, 'Cricket': 4};
  // Filter values
  Map<String, dynamic> selectedEvents = {};

  // Stakes filter values
  Map<String, dynamic> stakesFilterValues = {};

  // Odds Differential filter values (Back/Lay %)
  Map<String, dynamic> oddsDifferentialValues = {};

  // User filter values
  Map<String, dynamic> userFilterValues = {};

  // IP/ISP filter values
  Map<String, dynamic> ipispFilterValues = {};

  // Back/Lay time gap filter values
  Map<String, dynamic> backLayTimeGapValues = {};
  Map<String, dynamic> backLayODValues = {};
  List<String> get statuses => exchangeStatuses.map((option) => option.label).toList();
  // Helper to build bet status params from the current status selection
  Map<String, dynamic> getStatusParams() {
    final selected = exchangeStatuses.firstWhere((option) => option.label == selectedStatus, orElse: () => exchangeStatuses.first);
    return {'isDone': selected.isDone, 'status': selected.status};
  }

  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<BetData>> _pageCache = {};

  @override
  void initState() {
    context.read<FetchRiskMonitoringBloc>().add(FetchRiskMonitoringInt());
    super.initState();
  }

  // Helper to get sport ID
  int getSelectedSportId() {
    return sportsListForRM[selectedSport] ?? 4;
  }

  // Helper function to fetch bet list
  void fetchRiskMonitoring({required String from, required String to, int page = 1}) {
    if (page == 1) {
      _pageCache.clear();
    }

    int sid = getSelectedSportId();
    final statusData = getStatusParams();
    if (statusData['isDone'] == null || statusData['status'] == null) {
      context.read<FetchRiskMonitoringBloc>().add(FetchRiskMonitoringInt());
      return;
    }

    // Get userId from userFilterValues if filter is active
    String? userId;
    if (userFilterValues['switchStatus'] == true) {
      userId = userFilterValues['userId'];
    }

    ///for ip isp filter
    String? ip;
    String? isp;
    if (ipispFilterValues['switchStatus'] == true) {
      ip = ipispFilterValues['ipValue'];
      isp = ipispFilterValues['ispValue'];
    }

    ///for stakes filter
    double? stake;
    bool? stakeGreater;
    if (stakesFilterValues['switchStatus'] == true) {
      stakeGreater = true;
      stake = double.tryParse(stakesFilterValues['stake'] ?? '');
    }

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

    ///selected back/lay time gap values
    bool? sameSelectionBL;
    bool? diffSelectionBB;
    bool? diffSelectionLL;
    int timePeriod = 1;

    if (backLayODValues.isNotEmpty) {
      if (backLayODValues['sameSelectionBL'] != null && backLayODValues['sameSelectionBL'] == true) {
        sameSelectionBL = true;
        timePeriod = backLayTimeGapValues['sameSelectionBL'] ?? 1;
      } else if (backLayODValues['diffSelectionBB'] != null && backLayODValues['diffSelectionBB'] == true) {
        diffSelectionBB = true;
        timePeriod = backLayTimeGapValues['diffSelectionBB'] ?? 1;
      } else if (backLayODValues['diffSelectionLL'] != null && backLayODValues['diffSelectionLL'] == true) {
        diffSelectionLL = true;
        timePeriod = backLayTimeGapValues['diffSelectionLL'] ?? 1;
      }
    } else {
      sameSelectionBL = true;
      timePeriod = 1;
    }

    ///selected events and markets
    final String? eventIds = joinIds(selectedEvents['eventIds']);
    final String? marketIds = joinIds(selectedEvents['marketIds']);

    currentPage = page;

    context.read<FetchRiskMonitoringBloc>().add(
      FetchRiskMonitoring(
        fromDate: from,
        toDate: to,
        sid: sid,
        isDone: statusData['isDone'] as bool?,
        status: statusData['status'] as String?,
        userId: userId,
        bettingType: 0,
        ip: ip,
        isp: isp,
        page: page,
        limit: 10,
        stake: stake,
        stakeGreater: stakeGreater,
        diffOdds: diffOdds,
        oddDiffGreater: oddsDiffGreater,
        side: side,
        eventIds: eventIds,
        marketIds: marketIds,
        sameSelectionBL: sameSelectionBL,
        diffSelectionBB: diffSelectionBB,
        diffSelectionLL: diffSelectionLL,
        timePeriod: timePeriod,
      ),
    );
    context.read<FetchOrderEventsBloc>().add(
      FetchOrderEvents(
        fromDate: from,
        toDate: to,
        sid: sid,
        isDone: statusData['isDone'] as bool?,
        status: statusData['status'] as String?,
        userId: userId,
        bettingType: 0,
        ip: ip,
        isp: isp,
        page: page,
        limit: 10,
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
    fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text, page: safePage);
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
              RiskHeader(type: 1, title: "Risk Monitoring"),
              // Sports selection radios
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: sportsListForRM.keys.map((sport) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: sport,
                        groupValue: selectedSport,
                        onChanged: (value) {
                          setState(() {
                            selectedSport = value!;
                          });
                        },
                      ),
                      HighlightText(sport, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }).toList(),
              ),
              hb12,

              // Filter overlays
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  EventsFilterOverlayNew(
                    width: 130,
                    onSubmitted: (events) {
                      setState(() {
                        selectedEvents = events;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                  StakesFilterOverlay(
                    width: 130,
                    onSubmitted: (values) {
                      setState(() {
                        stakesFilterValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                  OddsDifferentialFilterOverlay(
                    width: 220,
                    onSubmitted: (values) {
                      setState(() {
                        oddsDifferentialValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                  BackLayTimeGapFilterOverlay(
                    onSubmitted: (values) {
                      setState(() {
                        backLayTimeGapValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                  BackLayOddsDifferentialOverlay(
                    onSubmitted: (values) {
                      setState(() {
                        backLayODValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),

                  ///Back / Lay Time Gap
                  UserFilterOverlay(
                    width: 130,
                    onSubmitted: (values) {
                      setState(() {
                        userFilterValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                  IPISPFilterOverlay(
                    width: 130,
                    onSubmitted: (values) {
                      setState(() {
                        ipispFilterValues = values;
                      });
                      fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text);
                    },
                  ),
                ],
              ),
              hb20,

              // Filter section with date pickers
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
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                            }
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
                        CustomOCTAButton(
                          title: 'Just For Today',
                          action: () {
                            final now = DateTime.now();
                            final dateText = now.toIso8601String().split('T').first;
                            fromDateController.text = dateText;
                            toDateController.text = dateText;
                            fetchRiskMonitoring(from: now.toIso8601String(), to: now.toIso8601String());
                          },
                        ),
                        CustomECTAButton(
                          title: 'Get History',
                          action: () {
                            validateAndSwapDates(fromDateController, toDateController);
                            fetchRiskMonitoring(from: fromDateController.text, to: toDateController.text, page: 1);
                          },
                        ),
                        BlocBuilder<FetchRiskMonitoringBloc, FetchRiskMonitoringState>(
                          builder: (context, fbl) {
                            List<BetData> betsListForTable = [];

                            if (fbl is FetchRiskMonitoringSuccess) {
                              betsListForTable = fbl.betsList;
                            }

                            return DownloadReport(
                              height: 30,
                              reportName: 'Risk Monitoring',
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

              /// table
              BlocBuilder<FetchRiskMonitoringBloc, FetchRiskMonitoringState>(
                builder: (context, fbl) {
                  List<BetData> betsList = [];
                  if (fbl is FetchRiskMonitoringSuccess) {
                    totalPages = fbl.response.totalPages;
                    _pageCache[fbl.response.page] = fbl.betsList;
                    betsList = _pageCache[currentPage] ?? [];
                  }

                  return fbl is FetchRiskMonitoringProgress
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
