import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/fetchBlocs/fetch_cg_history_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../../bloc/fetchBlocs/fetch_sports_book_pl_bloc.dart';
import '../../../reusable/button.dart';
import '../../../reusable/calender.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/formatters.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/snack_bar.dart';
import '../../logView/agencyLogHistory/balance_log_screen.dart';
import '../../riskView/riskManagement/riskManagementWidgets/risk_management_custom_widget.dart';
import 'casino_history_table.dart';
import 'exchange_pl_screen.dart';
import 'profit_and_loss_widgets.dart';
import 'sb_pl_screen.dart';

class ProfitAndLossScreen extends StatefulWidget {
  final String selectedUser;
  final bool embeddedMode;

  const ProfitAndLossScreen({super.key, this.selectedUser = '', this.embeddedMode = false});

  @override
  State<ProfitAndLossScreen> createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  int selectedTabIndex = 0;

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final ScrollController filterHorizontalController = ScrollController();
  final GlobalKey<ExchangePlScreenState> _exchangePlKey = GlobalKey<ExchangePlScreenState>();
  final GlobalKey<SportsBookPlScreenState> _sportsBookPlKey = GlobalKey<SportsBookPlScreenState>();

  // Map of tabs with their bettingType values
  final Map<String, int?> tabsMap = {'Exchange': 0, 'BookMaker': 2, 'FancyBet': 1, 'SportsBook': null, 'Casino': null};

  // Get tabs list from map keys
  List<String> get tabs => tabsMap.keys.toList();
  bool get isCasinoSelected => selectedTabIndex == 4;
  bool get isSportsBookSelected => selectedTabIndex == 3;

  @override
  void initState() {
    super.initState();
    if (widget.selectedUser.isNotEmpty) {
      userIdController.text = widget.selectedUser;
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    filterHorizontalController.dispose();
    super.dispose();
  }

  /// Returns null for tabs that should not trigger any API call.
  int? get bettingType {
    final selectedTab = tabs[selectedTabIndex];
    return tabsMap[selectedTab];
  }

  void _onTabTap(int index) {
    setState(() => selectedTabIndex = index);
    if (bettingType != null) {
      context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLossInt());
      return;
    }
    if (isCasinoSelected) {
      context.read<FetchCGHistoryBloc>().add(FetchCGHistoryInt());
      return;
    }
    if (isSportsBookSelected) {
      context.read<FetchSportBookPlBloc>().add(FetchSportBookPlInt());
      return;
    }
  }

  /// Common API trigger method
  void _fetchProfitLoss({required String from, required String to}) {
    if (userIdController.text.isEmpty) {
      showSnackBar(context, "userId is blank.", error: true);
      return;
    }

    if (bettingType == null && !isCasinoSelected) return;

    final Map<String, dynamic> data = {
      "userName": userIdController.text,
      "from": fromToDateTimeString(from, startOfDay: true),
      "to": fromToDateTimeString(to, startOfDay: false),
      "isDone": true,
      "status": 'filled',
    };

    if (isCasinoSelected) {
      setState(() => selectedTabIndex = tabs.indexOf('Casino'));
      context.read<FetchCGHistoryBloc>().add(FetchCGHistory(body: data));
    }
  }

  void _fetchHistory() {
    validateAndSwapDates(fromDateController, toDateController);
    final from = stringDateToDateTimeString(fromDateController.text, startOfDay: true);

    final to = stringDateToDateTimeString(toDateController.text);
    _fetchProfitLoss(from: from, to: to);
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
              if (!widget.embeddedMode) const RiskHeader(type: 1, title: "Profit/Loss"),

              if (!widget.embeddedMode) hb10,

              if (!widget.embeddedMode) ...[
                /// User Search
                Row(
                  children: [
                    RowTFF(controller: userIdController, hintText: "enter userId..."),
                    wb10,
                    CustomECTAButton(
                      title: 'Search',
                      action: () {
                        if (bettingType != null) {
                          _exchangePlKey.currentState?.fetchCustomHistory();
                          return;
                        }
                        if (isSportsBookSelected) {
                          _sportsBookPlKey.currentState?.fetchCustomHistory();
                          return;
                        }
                        _fetchHistory();
                      },
                    ),
                  ],
                ),
                hb30,
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
                      child: CustomTabBtn(tabs[index], isActive: selectedTabIndex == index, onTap: () => _onTabTap(index)),
                    ),
                  ),
                ),
              ),

              /// Filter Section
              if (bettingType != null) ExchangePlScreen(key: _exchangePlKey, userIdController: userIdController, bettingType: bettingType),
              if (isSportsBookSelected) SportsBookPlScreen(key: _sportsBookPlKey, userIdController: userIdController),
              if (isCasinoSelected) ...[
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
                              final from = stringDateToDateTimeString(now.toIso8601String(), startOfDay: true);
                              final to = stringDateToDateTimeString(now.toIso8601String());
                              _fetchProfitLoss(from: from, to: to);
                            },
                          ),
                          CustomOCTAButton(
                            title: 'From Yesterday',
                            action: () {
                              final now = DateTime.now();
                              final yesterday = now.subtract(const Duration(days: 1));
                              final fromText = yesterday.toIso8601String().split('T').first;
                              final toText = now.toIso8601String().split('T').first;
                              fromDateController.text = fromText;
                              toDateController.text = toText;
                              final from = stringDateToDateTimeString(yesterday.toIso8601String(), startOfDay: true);
                              final to = stringDateToDateTimeString(yesterday.toIso8601String());
                              _fetchProfitLoss(from: from, to: to);
                            },
                          ),
                          CustomECTAButton(title: 'Get History', action: _fetchHistory),
                        ],
                      ),
                      hb20,
                    ],
                  ),
                ),
                CasinoHistoryTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
