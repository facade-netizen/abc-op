import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../../../model/bm_book_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/highlighted_text_widget.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../reportsView/bettingHistory/betting_history_screen.dart';
import '../../reportsView/profitAndLoss/profit_and_loss_screen.dart';
import 'eventPlBook/event_pl_tile.dart';

class UserReportScreen extends StatefulWidget {
  const UserReportScreen({
    super.key,
    this.selectedUser = '',
    this.upline = const [],
  });
  final String selectedUser;
  final List<UplineData> upline;

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen> {
  final List<String> tabs = ['Bet History', 'Profit & Loss'];
  int selectedTabIndex = 0;
  List<UplineData> upline = [];

  @override
  void initState() {
    super.initState();
    upline = widget.upline;
    if (upline.isEmpty) {
      loadUplineFromStorage();
    }
  }

  void loadUplineFromStorage() {
    if (widget.selectedUser.isEmpty) return;
    final storageKey = 'user-report-upline-${widget.selectedUser}';
    final stored = html.window.localStorage[storageKey];
    if (stored == null || stored.isEmpty) return;

    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final parsed = decoded.map((e) => UplineData.fromJson(e as Map<String, dynamic>)).toList();
      if (widget.selectedUser.isNotEmpty) {
        parsed.add(
          UplineData(
            name: widget.selectedUser,
            title: 'PL',
            badgeColor: getBadgeColor('pl'),
          ),
        );
      }
      setState(() {
        upline = parsed;
      });
    } catch (_) {
      // ignore parsing errors
    } finally {
      html.window.localStorage.remove(storageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookHeaderBar(eventName: '', eventType: ''),
          hb10,
          if (upline.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: upline.map((u) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE4E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: u.badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            u.title.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          u.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          /// Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(
                tabs.length,
                (index) => UserReportTabCard(
                  title: tabs[index],
                  selectedTab: tabs[selectedTabIndex],
                  action: () {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: selectedTabIndex == 0
                ? BettingHistoryScreen(selectedUser: widget.selectedUser, embeddedMode: true)
                : ProfitAndLossScreen(selectedUser: widget.selectedUser, embeddedMode: true),
          ),
        ],
      ),
    );
  }
}

class UserReportTabCard extends StatelessWidget {
  const UserReportTabCard({
    super.key,
    this.action,
    required this.title,
    required this.selectedTab,
  });
  final String title;
  final String selectedTab;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        width: 230,
        height: 35,
        decoration: BoxDecoration(
          color: selectedTab == title ? tileOrFontColor : white,
          border: Border.all(color: black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HighlightText(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(color: selectedTab == title ? white : black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
