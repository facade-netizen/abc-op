import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../reusable/button.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/custom_table.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/loader.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../bloc/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../../model/players_profit_and_loss_model.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/exchange_pl_table_filter.dart';
import '../../../reusable/snack_bar.dart';
import 'exchange_pl_details.dart';
import 'profit_and_loss_widgets.dart';

class ExchangePlScreen extends StatefulWidget {
  const ExchangePlScreen({super.key, this.bettingType, required this.userIdController});

  final int? bettingType;
  final TextEditingController userIdController;

  @override
  State<ExchangePlScreen> createState() => ExchangePlScreenState();
}

class ExchangePlScreenState extends State<ExchangePlScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  /// Pagination
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<PlayerProfitAndLossResponseResult>> _pageCache = {};
  final Set<int> expandedOrderIds = <int>{};
  String selectedSport = 'ALL';
  List<String> dropdownItems = ['ALL'];
  double totalPL = 0.0;

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExchangePlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bettingType != widget.bettingType) {
      setState(() {
        _pageCache.clear();
        expandedOrderIds.clear();
      });
    }
  }

  /// FETCH DATA
  void fetchBetHistory({required String from, required String to, int page = 1, bool clearCache = false}) {
    if (widget.userIdController.text.trim().isEmpty) {
      showSnackBar(context, "userId is blank.", error: true);
      return;
    }
    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
      expandedOrderIds.clear();
    }
    currentPage = page;

    final Map<String, dynamic> data = {"userName": widget.userIdController.text.trim(), "from": from, "to": to, "page": page, "limit": 10, "bettingType": widget.bettingType};
    context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLoss(getPlayerPl: data));
  }

  /// PAGINATION METHODS
  void fetchPage(int page) {
    final int safePage = page < 1 ? 1 : page;
    if (_pageCache.containsKey(safePage)) {
      setState(() {
        currentPage = safePage;
        selectedSport = 'ALL';
        expandedOrderIds.clear();
      });
      return;
    }
    if (safePage > totalPages && totalPages != 0) return;
    setState(() {
      currentPage = safePage;
      selectedSport = 'ALL';
      expandedOrderIds.clear();
    });
    // Fetch new page
    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);
    final to = stringDateToDateTimeString(toDateController.text, startOfDay: false);
    fetchBetHistory(from: from, to: to, page: safePage);
  }

  /// DATE FILTERS
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

  /// FILTERED DATA
  List<PlayerProfitAndLossResponseResult> get currentPageData {
    final data = _pageCache[currentPage] ?? [];
    if (selectedSport == 'ALL') {
      return data;
    }
    return data.where((e) => e.eventTypeName == selectedSport).toList();
  }

  /// HANDLE SUCCESS
  void handleSuccess(FetchPlayerProfitAndLossSuccess pps) {
    final response = pps.response;
    totalPages = response.totalPages;
    totalPL = response.totalPnl;

    /// Cache page data
    _pageCache[response.page] = response.data;

    /// Create sports list from all cached pages
    final Set<String> sports = {};
    for (final pageData in _pageCache.values) {
      for (final item in pageData) {
        if (item.eventTypeName.isNotEmpty) {
          sports.add(item.eventTypeName);
        }
      }
    }
    dropdownItems = ['ALL', ...sports.toList()..sort()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// FILTER SECTION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accountStatementHeaderBg,
            border: Border(
              top: BorderSide(color: tileOrFontColor, width: 5),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
              hb20,
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  CustomOCTAButton(title: 'Just For Today', action: fetchToday),
                  CustomOCTAButton(title: 'From Yesterday', action: fetchYesterday),
                  CustomECTAButton(title: 'Get History', action: fetchCustomHistory),
                ],
              ),
              hb20,
            ],
          ),
        ),

        BlocBuilder<FetchPlayerProfitAndLossBloc, FetchPlayerProfitAndLossState>(
          builder: (context, state) {
            // Handle success state - update cache and filter list
            if (state is FetchPlayerProfitAndLossSuccess) {
              handleSuccess(state);
            }

            // Show loader during progress
            if (state is FetchPlayerProfitAndLossProgress) {
              expandedOrderIds.clear();
              dropdownItems.clear();
              return const LoaderContainerWithMessage();
            }

            // Get filtered data from cache for current page
            final List<PlayerProfitAndLossResponseResult> pagedBets = currentPageData;

            return state is FetchPlayerProfitAndLossSuccess
                ? Column(
                    children: [
                      ExchangePlTableFilter(
                        totalPL: totalPL,
                        dropdownItems: dropdownItems,
                        selectedSport: selectedSport,
                        onSportChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedSport = value;
                            expandedOrderIds.clear();
                          });
                        },
                      ),
                      CustomPaginatedTable<PlayerProfitAndLossResponseResult>(
                        topPadding: 0,
                        emptyMessage: 'No Data Available',
                        columns: exchangePlColumns(
                          onTap: (bet) {
                            final key = pagedBets.indexOf(bet);
                            final bool isExpanded = expandedOrderIds.contains(key);
                            setState(() {
                              if (isExpanded) {
                                expandedOrderIds.remove(key);
                              } else {
                                expandedOrderIds.add(key);
                              }
                            });
                          },
                          isExpanded: (bet) => expandedOrderIds.contains(pagedBets.indexOf(bet)),
                        ),
                        data: pagedBets,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        rowKey: (bet) => pagedBets.indexOf(bet),
                        expandedRowIds: expandedOrderIds,
                        expandedRowBuilder: (bet) => ExpandedPlDetails(details: bet.details),
                        onPageTap: fetchPage,
                        onPrevious: () {
                          if (currentPage <= 1) return;
                          fetchPage(currentPage - 1);
                        },
                        onNext: () {
                          if (currentPage >= totalPages) return;
                          fetchPage(currentPage + 1);
                        },
                      ),
                    ],
                  )
                : const ExchangePlInfo();
          },
        ),
      ],
    );
  }
}
