import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../reusable/button.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/custom_table.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/loader.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../bloc/fetchBlocs/fetch_sports_book_pl_bloc.dart';
import '../../../model/sport_book_pl_model.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/exchange_pl_table_filter.dart';
import '../../../reusable/snack_bar.dart';
import 'profit_and_loss_widgets.dart';
import 'sb_pl_table_details.dart';

class SportsBookPlScreen extends StatefulWidget {
  const SportsBookPlScreen({super.key, required this.userIdController});
  final TextEditingController userIdController;

  @override
  State<SportsBookPlScreen> createState() => SportsBookPlScreenState();
}

class SportsBookPlScreenState extends State<SportsBookPlScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Pagination variables with caching
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<SportBookPlModel>> _pageCache = <int, List<SportBookPlModel>>{};
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

  /// COMMON FETCH METHOD
  void fetchBetHistory({required String from, required String to, int page = 1}) {
    if (widget.userIdController.text.isEmpty) {
      showSnackBar(context, "userId is blank.", error: true);
      return;
    }
    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
      expandedOrderIds.clear();
    }

    currentPage = page;

    final Map<String, dynamic> data = {"userName": widget.userIdController.text.trim(), "from": from, "to": to, "page": page, "limit": 10};
    context.read<FetchSportBookPlBloc>().add(FetchSportBookPl(body: data));
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
    final from = fromToDateTimeString(fromDateController.text, startOfDay: true);
    final to = fromToDateTimeString(toDateController.text, startOfDay: false);
    fetchBetHistory(from: from, to: to, page: safePage);
  }

  /// DATE FILTERS
  void fetchToday() {
    final now = DateTime.now();
    final dateText = now.toIso8601String().split('T').first;
    fromDateController.text = dateText;
    toDateController.text = dateText;
    final from = fromToDateTimeString(now.toIso8601String(), startOfDay: true);
    final to = fromToDateTimeString(now.toIso8601String(), startOfDay: false);

    fetchBetHistory(from: from, to: to, page: 1);
  }

  void fetchYesterday() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final fromText = yesterday.toIso8601String().split('T').first;
    final toText = now.toIso8601String().split('T').first;
    fromDateController.text = fromText;
    toDateController.text = toText;
    final from = fromToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
    final to = fromToDateTimeString(yesterday.toIso8601String(), startOfDay: false);

    fetchBetHistory(from: from, to: to, page: 1);
  }

  void fetchCustomHistory() {
    validateAndSwapDates(fromDateController, toDateController);
    final from = fromToDateTimeString(fromDateController.text, startOfDay: true);
    final to = fromToDateTimeString(toDateController.text, startOfDay: false);
    fetchBetHistory(from: from, to: to, page: 1);
  }

  List<SportBookPlModel> get _currentPageData {
    final data = _pageCache[currentPage] ?? [];
    if (selectedSport == 'ALL') {
      return data;
    }
    final selectedType = selectedSport.replaceFirst('S/R ', '');
    return data.where((bet) => bet.eventTypeName == selectedType).toList();
  }

  void _handleSuccess(FetchSportBookPlSuccess state) {
    final response = state.sportsBookResponse;
    totalPages = response.totalPages;
    totalPL = response.totalPl;

    /// Cache page data
    _pageCache[response.page] = response.data;

    /// Create sports list from all cached pages
    final Set<String> sports = {};
    for (final pageData in _pageCache.values) {
      for (final item in pageData) {
        if (item.eventTypeName.isNotEmpty) {
          sports.add('S/R ${item.eventTypeName}');
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
              PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),
              hb20,

              /// Action Buttons
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

        BlocBuilder<FetchSportBookPlBloc, FetchSportBookPlState>(
          builder: (context, state) {
            // Handle success state - update cache and filter list
            if (state is FetchSportBookPlSuccess) {
              _handleSuccess(state);
            }

            // Show loader during progress
            if (state is FetchSportBookPlProgress) {
              expandedOrderIds.clear();
              dropdownItems.clear();
              return const LoaderContainerWithMessage();
            }

            // Get filtered data from cache for current page
            final List<SportBookPlModel> pagedBets = _currentPageData;

            return state is FetchSportBookPlSuccess
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
                      CustomPaginatedTable<SportBookPlModel>(
                        emptyMessage: 'No Data Available',
                        topPadding: 0,
                        columns: sportBookPlColumns(
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
                        expandedRowBuilder: (bet) => SBPlDetails(details: bet.details),
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
