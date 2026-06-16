import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_cg_history_bloc.dart';
import '../../../model/casino_history_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import 'casino_history_table_details.dart';
import 'profit_and_loss_widgets.dart';

class CasinoHistoryTable extends StatefulWidget {
  const CasinoHistoryTable({super.key});

  @override
  State<CasinoHistoryTable> createState() => _CasinoHistoryTableState();
}

class _CasinoHistoryTableState extends State<CasinoHistoryTable> {
  final Set<int> _expandedIndexes = {};
  String selectedSport = 'ALL';
  List<CasinoHistoryData> filteredList = [];
  List<String> dropdownItems = [];
  double totalPL = 0.0;
  int currentPage = 1;
  static const int pageSize = 10;

  void _clearCachedData() {
    _expandedIndexes.clear();
    selectedSport = 'ALL';
    filteredList = [];
    dropdownItems = [];
    totalPL = 0.0;
    currentPage = 1;
  }

  int get totalPages {
    if (filteredList.isEmpty) return 1;
    return (filteredList.length / pageSize).ceil();
  }

  int get safeCurrentPage => currentPage.clamp(1, totalPages);

  int get currentPageStartIndex => (safeCurrentPage - 1) * pageSize;

  List<CasinoHistoryData> get pagedFilteredList {
    final int start = currentPageStartIndex;
    final int end = (start + pageSize).clamp(0, filteredList.length);
    return filteredList.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCGHistoryBloc, FetchCGHistoryState>(
      builder: (context, state) {
        if (state is FetchCGHistoryProgress) {
          _clearCachedData();
          return const LoaderContainerWithMessage();
        }

        if (state is FetchCGHistorySuccess) {
          filteredList = state.cgHistoryData.data;
          totalPL = filteredList.fold(0.0, (sum, item) => sum + item.pnl);
        } else {
          _clearCachedData();
        }

        return filteredList.isEmpty
            ? ExchangePlInfo()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hb10,

                  /// Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            HighlightText(
                              'Total P/L:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: black),
                            ),
                            const SizedBox(width: 5),
                            HighlightText(
                              formattedAmounts(totalPL),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: totalPL < 0 ? red : black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const CasinoTableHeader(),

                  /// Event List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pagedFilteredList.length,
                    itemBuilder: (context, index) {
                      final event = pagedFilteredList[index];
                      final int globalIndex = currentPageStartIndex + index;
                      final isExpanded = _expandedIndexes.contains(globalIndex);

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F8),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: HighlightText.rich(
                                      event.betType,
                                      textSpan: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          /// SPORT + ARROW
                                          TextSpan(
                                            text: (event.betType.toUpperCase()),
                                          ),
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                                          ),

                                          /// EVENT (MAIN LINE)
                                          TextSpan(
                                            text: 'LIVE',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          /// MARKET NAME + ARROW
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
                                          ),
                                          TextSpan(
                                            text: event.time != null ? formattedOnlyDate(event.time) : '',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedIndexes.remove(globalIndex);
                                        } else {
                                          _expandedIndexes.add(globalIndex);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          HighlightText(
                                            formattedAmounts(event.pnl),
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: (event.pnl) < 0 ? red : black,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            isExpanded ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                                            size: 18,
                                            color: grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded) CasinoPlDetails(report: event.report),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _PaginationBar(
                    currentPage: safeCurrentPage,
                    totalPages: totalPages,
                    onPageTap: (page) {
                      if (page == currentPage) return;
                      setState(() => currentPage = page);
                    },
                    onPrevious: () {
                      if (currentPage <= 1) return;
                      setState(() => currentPage -= 1);
                    },
                    onNext: () {
                      if (currentPage >= totalPages) return;
                      setState(() => currentPage += 1);
                    },
                  ),
                  hb30,
                ],
              );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  List<Widget> _buildPageButtons() {
    final List<Widget> buttons = [];

    void addPageButton(int page) {
      buttons.add(
        _PageIndexButton(
          label: '$page',
          isActive: page == currentPage,
          onTap: () => onPageTap(page),
        ),
      );
      buttons.add(const SizedBox(width: 4));
    }

    void addEllipsis() {
      buttons.add(const _PageEllipsis());
      buttons.add(const SizedBox(width: 4));
    }

    if (totalPages <= 11) {
      for (int page = 1; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    if (currentPage <= 6) {
      for (int page = 1; page <= 10; page++) {
        addPageButton(page);
      }
      addEllipsis();
      addPageButton(totalPages);
      return buttons;
    }

    if (currentPage >= totalPages - 5) {
      addPageButton(1);
      addEllipsis();
      for (int page = totalPages - 9; page <= totalPages; page++) {
        addPageButton(page);
      }
      return buttons;
    }

    addPageButton(1);
    addEllipsis();
    for (int page = currentPage - 4; page <= currentPage + 4; page++) {
      addPageButton(page);
    }
    addEllipsis();
    addPageButton(totalPages);
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentPage > 1;
    final bool canGoNext = currentPage < totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          label: 'Prev',
          enabled: canGoPrevious,
          onTap: onPrevious,
        ),
        const SizedBox(width: 6),
        ..._buildPageButtons(),
        const SizedBox(width: 6),
        _PageButton(
          label: 'Next',
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PageIndexButton extends StatelessWidget {
  const _PageIndexButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minWidth: 26),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black.withOpacity(0.75) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? Colors.black.withOpacity(0.3) : Colors.grey.shade400,
          ),
        ),
        child: HighlightText(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? const Color(0xFFE5B84D) : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: HighlightText(
        '...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey.shade400;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: HighlightText(
          label,
          style: TextStyle(
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
