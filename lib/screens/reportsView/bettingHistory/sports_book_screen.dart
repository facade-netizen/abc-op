import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import '../../../../model/bet_status_option.dart';
import '../../../../model/sports_book_model.dart';
import '../../../../reusable/button.dart';
import '../../../../reusable/calender.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/custom_table.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/loader.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import 'sports_book_details.dart';

class SportsBookScreen extends StatefulWidget {
  const SportsBookScreen({super.key, required this.userIdController, required this.betIdsController});
  final TextEditingController userIdController;
  final TextEditingController betIdsController;

  @override
  SportsBookScreenState createState() => SportsBookScreenState();
}

class SportsBookScreenState extends State<SportsBookScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String selectedStatus = 'Matched';

  List<String> get statuses => exchangeStatuses.map((option) => option.label).toList();

  // Pagination variables with caching
  int currentPage = 1;
  int totalPages = 1;
  final Map<int, List<SportsBookModel>> _pageCache = <int, List<SportsBookModel>>{};
  final Set<int> expandedOrderIds = <int>{};

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  /// Helper to format bet IDs as comma-separated string
  String? _formatBetIds() {
    final betIdsText = widget.betIdsController.text.trim();
    if (betIdsText.isEmpty) return null;
    // Split by comma, trim each ID, remove empty strings, and join back
    final ids = betIdsText.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).join(',');
    return ids.isEmpty ? null : ids;
  }

  /// ---------------- STATUS HELPER ----------------
  Map<String, dynamic> getStatusParams() {
    final selected = exchangeStatuses.firstWhere((option) => option.label == selectedStatus, orElse: () => exchangeStatuses.first);
    return {'isDone': selected.isDone, 'status': selected.status};
  }

  /// ---------------- COMMON FETCH METHOD ----------------
  void fetchBetHistory({required String from, required String to, int page = 1}) {
    final statusData = getStatusParams();
    if (statusData["status"] == null) {
      // Handle null status case
      return;
    }
    final formattedBetIds = _formatBetIds();
    final status = nullIfEmpty(statusData["status"]?.toString().toLowerCase());
    // When a new search/filter is applied, clear cache and reset to first page.
    if (page == 1) {
      _pageCache.clear();
      expandedOrderIds.clear();
    }

    currentPage = page;

    final Map<String, dynamic> data = {
      "userName": nullIfEmpty(widget.userIdController.text.trim()),
      "from": from,
      "to": to,
      "status": status == 'new' ? 'open' : status,
      "page": page,
      "limit": 10,
      "orderIds": formattedBetIds,
    };
    context.read<FetchSportsBookBloc>().add(FetchSportsBook(body: data));
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
    final from = fromToDateTimeString(fromDateController.text, startOfDay: true);
    final to = fromToDateTimeString(toDateController.text, startOfDay: false);
    fetchBetHistory(from: from, to: to, page: safePage);
  }

  /// ---------------- DATE FILTERS ----------------
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

        BlocBuilder<FetchSportsBookBloc, FetchSportsBookState>(
          builder: (context, state) {
            // Handle success state - update cache
            if (state is FetchSportsBookSuccess) {
              final response = state.sportsBookResponse;
              totalPages = response.totalPages;
              _pageCache[response.page] = response.data;
            }

            // Show loader during progress
            if (state is FetchSportsBookProgress) {
              return const LoaderContainerWithMessage();
            }

            // Get data from cache for current page
            final List<SportsBookModel> pagedBets = _pageCache[currentPage] ?? [];

            return pagedBets.isEmpty
                ? const BettingInfo()
                : CustomPaginatedTable<SportsBookModel>(
                    topPadding: 10,
                    columns: spForBettingHistory(
                      onTap: (bet) {
                        final bool isExpanded = expandedOrderIds.contains(bet.id);
                        setState(() {
                          if (isExpanded) {
                            expandedOrderIds.remove(bet.id);
                          } else {
                            expandedOrderIds.add(bet.id);
                          }
                        });
                      },
                      isExpanded: (bet) => expandedOrderIds.contains(bet.id),
                    ),
                    data: pagedBets,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    rowKey: (bet) => bet.id,
                    expandedRowIds: expandedOrderIds,
                    expandedRowBuilder: (bet) => SportsBookDetails(bet: bet),
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
    );
  }
}
