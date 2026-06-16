import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import '../../../model/bet_status_option.dart';
import '../../../model/player_bet_history_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/custom_table.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../logView/agencyLogHistory/balance_log_screen.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import '../profitAndLoss/profit_and_loss_widgets.dart';
import 'betting_history_details.dart';
import 'sports_book_details.dart';
import 'sports_book_screen.dart';

class BettingHistoryScreen extends StatefulWidget {
  final String selectedUser;
  final bool embeddedMode;
  const BettingHistoryScreen({super.key, this.selectedUser = '', this.embeddedMode = false});

  @override
  State<BettingHistoryScreen> createState() => _BettingHistoryScreenState();
}

class _BettingHistoryScreenState extends State<BettingHistoryScreen> {
  int selectedTabIndex = 0;

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController betIdsController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final ScrollController filterHorizontalController = ScrollController();
  final GlobalKey<SportsBookScreenState> sportsBookScreenKey = GlobalKey<SportsBookScreenState>();

  // Map of tabs with their bettingType values
  final Map<String, int?> tabsMap = {'Exchange': 0, 'BookMaker': 2, 'FancyBet': 1, 'SportsBook': null};

  // Get tabs list from map keys
  List<String> get tabs => tabsMap.keys.toList();

  String selectedStatus = 'Matched';

  List<BetStatusOption> get _currentStatusOptions {
    final currentTab = tabs[selectedTabIndex];
    if (currentTab == 'BookMaker' || currentTab == 'FancyBet') {
      return bookMakerStatuses;
    }
    return exchangeStatuses;
  }

  List<String> get statuses => _currentStatusOptions.map((option) => option.label).toList();
  bool get isSportsBookTab => tabs[selectedTabIndex] == 'SportsBook';

  // Pagination variables with caching
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<PlayerBetHistory>> _pageCache = <int, List<PlayerBetHistory>>{};
  final Set<int> expandedOrderIds = <int>{};

  @override
  void initState() {
    super.initState();
    userIdController.text = widget.selectedUser;
    context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
    context.read<FetchSportsBookBloc>().add(FetchSportsBookInt());
  }

  @override
  void dispose() {
    userIdController.dispose();
    betIdsController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    filterHorizontalController.dispose();
    super.dispose();
  }

  /// Helper to format bet IDs as comma-separated string
  String? _formatBetIds() {
    final betIdsText = betIdsController.text.trim();
    if (betIdsText.isEmpty) return null;
    // Split by comma, trim each ID, remove empty strings, and join back
    final ids = betIdsText.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).join(',');
    return ids.isEmpty ? null : ids;
  }

  int? get bettingType {
    final selectedTab = tabs[selectedTabIndex];
    return tabsMap[selectedTab];
  }

  /// ---------------- STATUS HELPER ----------------
  Map<String, dynamic> getStatusParams() {
    final selected = _currentStatusOptions.firstWhere((option) => option.label == selectedStatus, orElse: () => _currentStatusOptions.first);
    return {'isDone': selected.isDone, 'status': selected.status};
  }

  /// ---------------- COMMON FETCH METHOD ----------------

  void fetchBetHistory({required String from, required String to, int page = 1}) {
    final statusData = getStatusParams();
    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
      expandedOrderIds.clear();
    }

    currentPage = page;

    // Get formatted bet IDs
    final formattedBetIds = _formatBetIds();
    if (statusData["isDone"] == null || statusData["status"] == null) {
      if (!isSportsBookTab) {
        context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
      } else {
        context.read<FetchSportsBookBloc>().add(FetchSportsBookInt());
      }
      return;
    }

    final Map<String, dynamic> data = {
      "page": page,
      "limit": "10",
      "sid": null,
      "userName": nullIfEmpty(userIdController.text.trim()),
      "from": from,
      "to": to,
      "betIds": formattedBetIds,
      "bettingType": bettingType,
      "isDone": statusData["isDone"],
      "status": nullIfEmpty(statusData["status"]?.toString().toLowerCase()),
    };
    context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetHistory(getPlayerData: data));
  }

  T? nullIfEmpty<T>(T? value) {
    if (value == null) return null;

    if (value is String && value.trim().isEmpty) {
      return null;
    }

    return value;
  }

  /// ---------------- PAGINATION METHODS ----------------
  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (_pageCache.containsKey(safePage)) {
      setState(() => currentPage = safePage);
      return;
    }
    if (safePage > totalPages && totalPages != 0) return;
    currentPage = safePage;
    // Fetch new page
    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDateController.text, startOfDay: false);
    fetchBetHistory(from: from, to: to, page: safePage);
  }

  /// ---------------- DATE FILTERS ----------------
  void fetchToday() {
    final now = DateTime.now();
    final dateText = now.toIso8601String().split('T').first;
    fromDateController.text = dateText;
    toDateController.text = dateText;
    final from = stringDateToDateTimeString(now.toIso8601String(), startOfDay: true);
    final to = stringDateToDateTimeString(now.toIso8601String(), startOfDay: false);

    fetchBetHistory(from: from, to: to, page: 1);
  }

  void fetchYesterday() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final fromText = yesterday.toIso8601String().split('T').first;
    final toText = now.toIso8601String().split('T').first;
    fromDateController.text = fromText;
    toDateController.text = toText;
    final from = stringDateToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
    final to = stringDateToDateTimeString(yesterday.toIso8601String(), startOfDay: false);

    fetchBetHistory(from: from, to: to, page: 1);
  }

  void fetchCustomHistory() {
    validateAndSwapDates(fromDateController, toDateController);
    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDateController.text, startOfDay: false);

    fetchBetHistory(from: from, to: to, page: 1);
  }

  void onTabTap(int index) {
    setState(() {
      selectedTabIndex = index;
      _pageCache.clear();
      expandedOrderIds.clear();
      if (!statuses.contains(selectedStatus)) {
        selectedStatus = statuses.first;
      }
    });
    if (!isSportsBookTab) {
      context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
    } else {
      context.read<FetchSportsBookBloc>().add(FetchSportsBookInt());
    }
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
              if (!widget.embeddedMode) ...[
                const RiskHeader(type: 1, title: "Betting History"),
                hb20,

                /// EventId Filter (renamed to Bet IDs for clarity)
                Row(
                  children: [
                    RowTFF(controller: betIdsController, hintText: "enter betId...", width: 300),
                    wb8,
                    CustomECTAButton(
                      title: 'Submit',
                      action: () {
                        if (isSportsBookTab) {
                          sportsBookScreenKey.currentState?.fetchCustomHistory();
                          return;
                        } else {
                          fetchCustomHistory();
                        }
                      },
                    ),
                    wb10,
                    HighlightText('Multiple bet IDs allowed (e.g. 123,456,789)', style: TextStyle(color: black, fontSize: 12)),
                  ],
                ),

                const Divider(),
                hb10,

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowTFF(controller: userIdController, hintText: "enter userId...", width: 200),
                    hb20,
                  ],
                ),
              ],

              /// Tabs
              SingleChildScrollView(
                controller: filterHorizontalController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    tabs.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: CustomTabBtn(tabs[index], isActive: selectedTabIndex == index, onTap: () => onTabTap(index)),
                    ),
                  ),
                ),
              ),
              if (!isSportsBookTab) ...[
                /// Filter Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accountStatementHeaderBg,
                    border: Border(
                      top: BorderSide(color: tileOrFontColor, width: 5),
                      bottom: BorderSide(color: borderColor),
                    ),
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
                                setState(() => selectedStatus = value);
                              }
                            },
                          ),
                          PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
                        ],
                      ),
                      hb20,

                      /// Action Buttons
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          CustomOCTAButton(title: 'Just For Today', action: fetchToday),
                          CustomOCTAButton(title: 'Yesterday', action: fetchYesterday),
                          CustomECTAButton(title: 'Get History', action: fetchCustomHistory),
                        ],
                      ),
                    ],
                  ),
                ),

                ///
                BlocBuilder<FetchPlayerBetHistoryBloc, FetchPlayerBetHistoryState>(
                  builder: (context, state) {
                    // Handle success state - update cache
                    if (state is FetchPlayerBetHistorySuccess) {
                      final response = state.res;
                      totalPages = response.totalPages;
                      _pageCache[response.page] = response.data;
                    }

                    // Show loader during progress
                    if (state is FetchPlayerBetHistoryProgress) {
                      return const LoaderContainerWithMessage();
                    }

                    // Get data from cache for current page
                    final List<PlayerBetHistory> pagedBets = _pageCache[currentPage] ?? [];

                    return pagedBets.isEmpty
                        ? const BettingInfo()
                        : CustomPaginatedTable<PlayerBetHistory>(
                            columns: exchangeBettingHistory(
                              onTap: (bet) {
                                final bool isExpanded = expandedOrderIds.contains(bet.orderId);
                                setState(() {
                                  if (isExpanded) {
                                    expandedOrderIds.remove(bet.orderId);
                                  } else {
                                    expandedOrderIds.add(bet.orderId);
                                  }
                                });
                              },
                              isExpanded: (bet) => expandedOrderIds.contains(bet.orderId),
                            ),
                            data: pagedBets,
                            currentPage: currentPage,
                            totalPages: totalPages,
                            rowKey: (bet) => bet.orderId,
                            expandedRowIds: expandedOrderIds,
                            expandedRowBuilder: (bet) => BettingHistoryDetails(bet: bet),
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
              if (isSportsBookTab) SportsBookScreen(userIdController: userIdController, betIdsController: betIdsController, key: sportsBookScreenKey),
            ],
          ),
        ),
      ),
    );
  }
}
