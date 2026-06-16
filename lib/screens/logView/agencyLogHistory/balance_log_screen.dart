import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_balance_summary_log_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_cg_balance_history_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_sports_book_bloc.dart';
import '../../../model/balance_summary_logs_model.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../../reusable/style.dart';
import '../../filterOverlay/download_report.dart';
import '../../reportsView/profitAndLoss/profit_and_loss_widgets.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import '../../riskView/riskMonitoring/row_dropdown.dart';
import 'casino_balance_log_screen.dart';
import 'sb_balance_log_screen.dart';

class BalanceLogGroup {
  final bool isNAGroup;
  final List<BalanceLogSummaryItem> logs;
  BalanceLogGroup({required this.isNAGroup, required this.logs});
}

class BalanceLogScreen extends StatefulWidget {
  const BalanceLogScreen({super.key});

  @override
  State<BalanceLogScreen> createState() => _BalanceLogScreenState();
}

class _BalanceLogScreenState extends State<BalanceLogScreen> {
  ///
  String selectedLogType = 'Balance Log';
  final List<String> logTypes = ['Balance Log', 'Negative After Balance', 'Casino Balance Log', 'SportsBook Balance Log'];
  bool get isCasinoLog => selectedLogType == 'Casino Balance Log';
  bool get isSportsBookLog => selectedLogType == 'SportsBook Balance Log';
  bool get isNegativeAfterBalanceLog => selectedLogType == 'Negative After Balance';

  ///
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController eventIdsController = TextEditingController();
  final TextEditingController marketIdsController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  static const double _rowHeight = 35;

  List<BalanceLogSummaryItem> _balanceLogs = [];
  BalanceLogSummaryResponse? _balanceLogResponse;
  Map<String, dynamic>? _currentRequest;
  final Map<int, List<BalanceLogSummaryItem>> _pageCache = {};
  bool _isLoading = false;

  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _currentRequest = null;
    _pageCache.clear();
  }

  @override
  void dispose() {
    userIdController.dispose();
    eventIdsController.dispose();
    marketIdsController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  int get _totalPages => _balanceLogResponse?.totalPages ?? 1;

  void _applyFilters({int page = 1}) {
    final userId = userIdController.text.trim();
    final eventIds = eventIdsController.text.trim();
    final marketIds = marketIdsController.text.trim();

    if (userId.isEmpty && !isNegativeAfterBalanceLog) {
      showSnackBar(context, "userId is blank.", error: true);
      return;
    }

    ///
    if (isNegativeAfterBalanceLog && (eventIds.isEmpty || marketIds.isEmpty)) {
      showSnackBar(context, 'Query negative balance, Event Id & Market Id must be provided.', error: true);
      return;
    }

    if (userId.contains(',') && (eventIds.isEmpty || marketIds.isEmpty)) {
      showSnackBar(context, "When querying multiple userIds at once, eventId and marketId are mandatory fields that must be provided.", error: true);
      return;
    }
    validateAndSwapDates(fromDateController, toDateController);
    final from = fromDateController.text.isNotEmpty ? fromToDateTimeString(fromDateController.text, startOfDay: true) : '';
    final to = toDateController.text.isNotEmpty ? fromToDateTimeString(toDateController.text, startOfDay: false) : '';
    final request = {if (!isNegativeAfterBalanceLog) "userName": userId, "from": from, "to": to, "page": page, "marketIds": marketIds, "eventIds": eventIds, "limit": _pageSize};

    setState(() {
      _currentPage = page;
      _currentRequest = request;
      _isLoading = true;
      _pageCache.clear();
    });

    context.read<FetchBalanceSummaryLogBloc>().add(FetchBalanceSummaryLog(getPlayerData: request, isNegativeAfterBalanceLog: isNegativeAfterBalanceLog));
  }

  void _changePage(int page) {
    if (_currentRequest == null || page == _currentPage || page < 1 || page > _totalPages) return;

    if (_pageCache.containsKey(page)) {
      setState(() {
        _currentPage = page;
        _balanceLogs = _pageCache[page]!;
      });
      return;
    }

    final request = Map<String, dynamic>.from(_currentRequest!);
    request['page'] = page;

    setState(() {
      _currentPage = page;
      _currentRequest = request;
      _isLoading = true;
    });

    context.read<FetchBalanceSummaryLogBloc>().add(FetchBalanceSummaryLog(getPlayerData: request, isNegativeAfterBalanceLog: isNegativeAfterBalanceLog));
  }

  List<BalanceLogGroup> _buildGroups(List<BalanceLogSummaryItem> logs) {
    final groups = <BalanceLogGroup>[];

    int i = 0;
    while (i < logs.length) {
      final current = logs[i];
      final isNA = current.eventId == 'NA' && current.categoryType == 'NA';

      if (isNA) {
        final naLogs = <BalanceLogSummaryItem>[];
        while (i < logs.length) {
          final item = logs[i];
          final sameNA = item.eventId == 'NA' && item.categoryType == 'NA';
          if (!sameNA) break;
          naLogs.add(item);
          i++;
        }
        groups.add(BalanceLogGroup(isNAGroup: true, logs: naLogs));
        continue;
      }

      final groupedLogs = <BalanceLogSummaryItem>[];
      while (i < logs.length) {
        final item = logs[i];
        final isItemNA = item.eventId == 'NA' && item.categoryType == 'NA';

        if (isItemNA) break;

        // Dynamic grouping logic
        final bool shouldGroup = _shouldGroupTogether(current, item);

        if (!shouldGroup) {
          break;
        }

        groupedLogs.add(item);
        i++;
      }
      groups.add(BalanceLogGroup(isNAGroup: false, logs: groupedLogs));
    }

    return groups;
  }

  bool _shouldGroupTogether(BalanceLogSummaryItem current, BalanceLogSummaryItem item) {
    // Case 1: Same eventId AND eventName
    final bool sameEvent = current.eventId == item.eventId && current.eventName == item.eventName;

    // Case 2: Same marketId AND marketName
    final bool sameMarket = current.marketId == item.marketId && current.marketName == item.marketName;

    // Case 3: Same eventId, eventName, marketId, marketName (all four)
    final bool allFourSame = sameEvent && sameMarket;

    // Group if ANY of these conditions match
    // Priority: allFourSame > sameEvent > sameMarket
    if (allFourSame) return true;
    if (sameEvent) return true;
    if (sameMarket) return true;

    return false;
  }

  Widget buildBalanceLogTable(List<BalanceLogSummaryItem> logs) {
    final groupedLogs = _buildGroups(logs);

    final userSiteGroups = <String, List<BalanceLogGroup>>{};

    for (final group in groupedLogs) {
      final first = group.logs.first;

      final key = '${first.userId}||${first.site}';

      userSiteGroups.putIfAbsent(key, () => []);

      userSiteGroups[key]!.add(group);
    }

    final columnFlex = _computeColumnFlex();

    return Container(
      color: white,
      child: Column(children: [buildTableHeaderRow(columnFlex), for (final userGroup in userSiteGroups.values) _buildUserSiteGroupBlockV2(userGroup, columnFlex)]),
    );
  }

  Widget _buildUserSiteGroupBlockV2(List<BalanceLogGroup> groups, Map<String, int> flexes) {
    final totalRows = groups.fold(0, (sum, e) => sum + e.logs.length);

    final first = groups.first.logs.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: flexes['userId']!,
          child: tableBodyCell(first.userName, height: totalRows * _rowHeight, leftBorder: true),
        ),
        Expanded(
          flex: flexes['site']!,
          child: tableBodyCell(first.site, height: totalRows * _rowHeight),
        ),
        Expanded(
          flex: 146,
          child: Column(
            children: groups.map((group) {
              return group.isNAGroup ? _buildNABlock(group.logs, flexes) : _buildGroupedBlock(group.logs, flexes);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedBlock(List<BalanceLogSummaryItem> logs, Map<String, int> flexes) {
    final height = logs.length * _rowHeight;

    // Check if all rows in group have same event
    final bool sameEvent = logs.every((log) => log.eventId == logs.first.eventId && log.eventName == logs.first.eventName);

    // Check if all rows in group have same market
    final bool sameMarket = logs.every((log) => log.marketId == logs.first.marketId && log.marketName == logs.first.marketName);

    // Check if all rows have same category
    final bool sameCategory = logs.every((log) => log.categoryType == logs.first.categoryType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EventId - merge if same across all rows
        Expanded(
          flex: flexes['eventId']!,
          child: sameEvent
              ? tableBodyCell(logs.first.eventId.toString(), height: height)
              : Column(
                  children: logs
                      .map(
                        (log) => SizedBox(
                          height: _rowHeight,
                          child: tableBodyCell(log.eventId.toString(), height: _rowHeight),
                        ),
                      )
                      .toList(),
                ),
        ),

        // EventName - merge if same across all rows
        Expanded(
          flex: flexes['eventName']!,
          child: sameEvent
              ? tableBodyCell(logs.first.eventName, height: height)
              : Column(
                  children: logs
                      .map(
                        (log) => SizedBox(
                          height: _rowHeight,
                          child: tableBodyCell(log.eventName, height: _rowHeight),
                        ),
                      )
                      .toList(),
                ),
        ),

        // MarketId - merge if same across all rows
        Expanded(
          flex: flexes['marketId']!,
          child: sameMarket
              ? tableBodyCell(logs.first.marketId, height: height)
              : Column(
                  children: logs
                      .map(
                        (log) => SizedBox(
                          height: _rowHeight,
                          child: tableBodyCell(log.marketId, height: _rowHeight),
                        ),
                      )
                      .toList(),
                ),
        ),

        // MarketName - merge if same across all rows
        Expanded(
          flex: flexes['marketName']!,
          child: sameMarket
              ? tableBodyCell(logs.first.marketName, height: height)
              : Column(
                  children: logs
                      .map(
                        (log) => SizedBox(
                          height: _rowHeight,
                          child: tableBodyCell(log.marketName, height: _rowHeight),
                        ),
                      )
                      .toList(),
                ),
        ),

        // CategoryType - merge if same across all rows
        Expanded(
          flex: flexes['categoryType']!,
          child: sameEvent && sameMarket && sameCategory
              ? tableBodyCell(logs.first.categoryType.toString(), height: height)
              : Column(
                  children: logs
                      .map(
                        (log) => SizedBox(
                          height: _rowHeight,
                          child: tableBodyCell(log.categoryType.toString(), height: _rowHeight),
                        ),
                      )
                      .toList(),
                ),
        ),

        // Balance columns (always show per row)
        Expanded(
          flex: flexes['beforeBalance']! + flexes['afterBalance']! + flexes['profitLoss']! + flexes['remark']! + flexes['createDate']!,
          child: Column(children: logs.map((log) => _buildBalanceRow(log, flexes)).toList()),
        ),
      ],
    );
  }

  Widget _buildNABlock(List<BalanceLogSummaryItem> logs, Map<String, int> flexes) {
    final height = logs.length * _rowHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: flexes['eventId']!,
          child: tableBodyCell('N/A', height: height),
        ),
        Expanded(
          flex: flexes['eventName']!,
          child: tableBodyCell('N/A', height: height),
        ),
        Expanded(
          flex: flexes['marketId']!,
          child: tableBodyCell('N/A', height: height),
        ),
        Expanded(
          flex: flexes['marketName']!,
          child: tableBodyCell('N/A', height: height),
        ),
        Expanded(
          flex: flexes['categoryType']!,
          child: tableBodyCell('N/A', height: height),
        ),
        Expanded(
          flex: flexes['beforeBalance']! + flexes['afterBalance']! + flexes['profitLoss']! + flexes['remark']! + flexes['createDate']!,
          child: Column(children: logs.map((e) => _buildBalanceRow(e, flexes)).toList()),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(BalanceLogSummaryItem log, Map<String, int> flexes) {
    return Row(
      children: [
        Expanded(
          flex: flexes['beforeBalance']!,
          child: tableBodyCell(formattedAmounts(log.beforeBalance), color: log.beforeBalance >= 0 ? black : red),
        ),
        Expanded(
          flex: flexes['afterBalance']!,
          child: tableBodyCell(formattedAmounts(log.afterBalance), color: log.afterBalance >= 0 ? black : red),
        ),
        Expanded(
          flex: flexes['profitLoss']!,
          child: tableBodyCell(formattedAmounts(log.profitLoss), color: log.profitLoss >= 0 ? black : red),
        ),
        Expanded(flex: flexes['remark']!, child: tableBodyCell(log.remark)),
        Expanded(flex: flexes['createDate']!, child: tableBodyCell(log.createDate.isNotEmpty ? formattedDate(log.createDate) : '')),
      ],
    );
  }

  Map<String, int> _computeColumnFlex() {
    return {
      'userId': 12,
      'site': 8,
      'eventId': 12,
      'eventName': 30,
      'marketId': 12,
      'marketName': 14,
      'categoryType': 10,
      'beforeBalance': 12,
      'afterBalance': 12,
      'profitLoss': 12,
      'remark': 20,
      'createDate': 12,
    };
  }

  Widget buildTableHeaderRow(Map<String, int> flexes) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: flexes['userId']!, child: tableHeaderCell('UserId')),
          Expanded(flex: flexes['site']!, child: tableHeaderCell('Site')),
          Expanded(flex: flexes['eventId']!, child: tableHeaderCell('EventId')),
          Expanded(flex: flexes['eventName']!, child: tableHeaderCell('EventName')),
          Expanded(flex: flexes['marketId']!, child: tableHeaderCell('MarketId')),
          Expanded(flex: flexes['marketName']!, child: tableHeaderCell('MarketName')),
          Expanded(flex: flexes['categoryType']!, child: tableHeaderCell('Category Type')),
          Expanded(flex: flexes['beforeBalance']!, child: tableHeaderCell('Before Total Balance')),
          Expanded(flex: flexes['afterBalance']!, child: tableHeaderCell('After Total Balance')),
          Expanded(flex: flexes['profitLoss']!, child: tableHeaderCell('Profit / Loss')),
          Expanded(flex: flexes['remark']!, child: tableHeaderCell('Remark')),
          Expanded(flex: flexes['createDate']!, child: tableHeaderCell('Create Date')),
        ],
      ),
    );
  }

  Widget tableHeaderCell(String text) {
    return Container(
      height: _rowHeight,
      alignment: Alignment.center,
      child: HighlightText(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: headerTextColor),
      ),
    );
  }

  Widget tableBodyCell(String text, {Color color = black, bool topBorder = false, bool bottomBorder = true, bool leftBorder = false, bool rightBorder = true, double? height}) {
    return Container(
      height: height ?? _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          left: leftBorder ? BorderSide(color: borderColor) : BorderSide.none,
          right: rightBorder ? BorderSide(color: borderColor) : BorderSide.none,
          top: topBorder ? BorderSide(color: borderColor) : BorderSide.none,
          bottom: bottomBorder ? BorderSide(color: borderColor) : BorderSide.none,
        ),
      ),
      child: HighlightText(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: color),
      ),
    );
  }

  Widget buildPaginationBar() {
    final pages = List<int>.generate(_totalPages, (index) => index + 1);
    final visiblePages = pages.length <= 7
        ? pages
        : pages.where((page) {
            if (page <= 3 || page > _totalPages - 3) return true;
            return (page - _currentPage).abs() <= 1;
          }).toList();

    Widget pageButton(int page) {
      final bool isActive = page == _currentPage;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          onPressed: isActive ? null : () => _changePage(page),
          style: TextButton.styleFrom(
            backgroundColor: isActive ? blue : Colors.white,
            foregroundColor: isActive ? white : black,
            minimumSize: const Size(36, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(color: isActive ? white : black, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
          ),
        ),
      );
    }

    Widget navButton(String label, VoidCallback? action, bool enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          onPressed: enabled ? action : null,
          style: TextButton.styleFrom(
            backgroundColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
            foregroundColor: enabled ? Colors.black87 : Colors.black38,
            minimumSize: const Size(48, 34),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(label),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        navButton('Prev', () => _changePage(_currentPage - 1), _currentPage > 1),
        ...visiblePages.expand<Widget>((page) {
          final pageIndex = visiblePages.indexOf(page);
          final widgets = <Widget>[];
          if (pageIndex > 0 && visiblePages[pageIndex - 1] != page - 1) {
            widgets.add(
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(color: Colors.black54)),
              ),
            );
          }
          widgets.add(pageButton(page));
          return widgets;
        }),
        navButton('Next', () => _changePage(_currentPage + 1), _currentPage < _totalPages),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocListener<FetchBalanceSummaryLogBloc, FetchBalanceSummaryLogState>(
      listener: (context, state) {
        if (state is FetchBalanceSummaryLogProgress) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is FetchBalanceSummaryLogSuccess) {
          setState(() {
            _isLoading = false;
            _balanceLogs = state.summaryItems;
            _balanceLogResponse = state.response;
            _currentPage = state.response.page;
            _pageCache[state.response.page] = state.summaryItems;
          });
        } else if (state is FetchBalanceSummaryLogFailure) {
          setState(() {
            _isLoading = false;
            _balanceLogs = [];
            _balanceLogResponse = null;
          });
        }
      },
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RiskHeader(type: 1, title: "Balance Log"),
                hb10,
                RowDropdown<String>(
                  width: 200,
                  title: 'Mod',
                  value: selectedLogType,
                  items: logTypes,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLogType = value;
                        _balanceLogs = [];
                        userIdController.clear();
                        eventIdsController.clear();
                        marketIdsController.clear();
                        context.read<FetchBalanceSummaryLogBloc>().add(FetchBalanceSummaryLogInt());
                        if (isCasinoLog) context.read<FetchCGBalanceHistoryBloc>().add(FetchCGBalanceHistoryInt());
                        if (isSportsBookLog) context.read<FetchSportsBookBloc>().add(FetchSportsBookInt());
                      });
                    }
                  },
                ),
                hb10,
                if (isCasinoLog) const CasinoBalanceLogScreen(),
                if (isSportsBookLog) const SbBalanceLogScreen(),
                if (!isCasinoLog && !isSportsBookLog) ...[
                  /// FILTER SECTION
                  Container(
                    decoration: BoxDecoration(
                      color: accountStatementHeaderBg,
                      border: Border(bottom: BorderSide(color: borderColor)),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hb10,

                        /// FILTERS
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            /// EVENT ID
                            RowTFF(title: isNegativeAfterBalanceLog ? '*eventId:' : 'eventId:', controller: eventIdsController, hintText: "enter eventId..."),

                            /// MARKET ID
                            RowTFF(title: isNegativeAfterBalanceLog ? '*marketId:' : 'marketId:', controller: marketIdsController, hintText: "enter marketId..."),

                            /// USER ID
                            if (!isNegativeAfterBalanceLog) RowTFF(title: '*userId:', controller: userIdController, hintText: "enter userId..."),

                            /// DATE FILTER
                            PeriodFilterCard(fromDateController: fromDateController, toDateController: toDateController),

                            /// SUBMIT
                            CustomECTAButton(title: 'Submit', action: _applyFilters),

                            /// DOWNLOAD
                            DownloadReport(
                              reportName: "Balance Log",
                              headerTitles: [
                                'UserId',
                                'Site',
                                'EventId',
                                'EventName',
                                'MarketId',
                                'MarketName',
                                'Category Type',
                                'Before Total Balance',
                                'After Total Balance',
                                'Profit / Loss',
                                'Remark',
                                'Create Date',
                              ],
                              rowData: _balanceLogs.map((row) {
                                return [
                                  row.userName,
                                  row.site,
                                  row.eventId,
                                  row.eventName,
                                  row.marketId,
                                  row.marketName,
                                  row.categoryType,
                                  formattedAmounts(row.beforeBalance),
                                  formattedAmounts(row.afterBalance),
                                  formattedAmounts(row.profitLoss),
                                  row.remark,
                                  row.createDate,
                                ];
                              }).toList(),
                            ),
                          ],
                        ),
                        hb20,
                        const Heading(isBold: false, '1. When querying multiple userIds at once, eventId and marketId are mandatory fields that must be provided.'),
                        const Heading(isBold: false, '2. When querying with multiple userIds, please separate the accounts using a comma (,).'),
                        const Heading(isBold: false, '3. The maximum limit for each query is 500 userIds.'),
                        const Heading(isBold: false, '4. With Negative After Balance mode enabled, use Event Id & Market Id to sort negative After Balance records.'),
                        const Heading(isBold: false, '5. The Balance Log retains records from the past 62 days for querying.'),
                        hb20,
                      ],
                    ),
                  ),
                  hb10,

                  if (_isLoading)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: LoaderContainerWithMessage())
                  else ...[
                    buildBalanceLogTable(_balanceLogs),
                    if (_balanceLogs.isNotEmpty) ...[const SizedBox(height: 10), buildPaginationBar()],
                  ],
                  hb12,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RowTFF extends StatelessWidget {
  const RowTFF({super.key, this.controller, this.title, required this.hintText, this.width = 160});
  final TextEditingController? controller;
  final String? title;
  final String hintText;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (title != null) HighlightText(title!),
        SizedBox(
          height: 30,
          width: width,
          child: TextFormField(
            controller: controller,
            decoration: tfInputDecoration.copyWith(hintText: hintText, contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
          ),
        ),
      ],
    );
  }
}
