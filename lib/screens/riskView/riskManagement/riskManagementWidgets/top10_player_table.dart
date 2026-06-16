import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

import '../../../../model/top_exposure_player_model.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/formatters.dart';
import '../../../../reusable/highlighted_text_widget.dart';
import '../../../../reusable/sized_box_hw.dart';
import '../../../../router/route_paths.dart';
import 'risk_management_custom_widget.dart';

class Top10TabScreen extends StatefulWidget {
  const Top10TabScreen({super.key, required this.topBalance, required this.topExposure});
  final List<TopPlayerExposureData> topBalance;
  final List<TopPlayerExposureData> topExposure;
  @override
  State<Top10TabScreen> createState() => _Top10TabScreenState();
}

class _Top10TabScreenState extends State<Top10TabScreen> {
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width * 0.6,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          TableHeader(selectedTabIndex: selectedTabIndex),
          Container(
            color: white,
            child: Column(children: _buildTableRows(selectedTabIndex == 0 ? widget.topBalance : widget.topExposure)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(color: tileOrFontColor),
      height: 30,
      child: Row(children: [_buildTabItem("Top 10 Matched Amount Player", 0), _buildTabItem("Top 10 Exposure Player", 1)]),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool selected = selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: ClipPath(
        clipper: TabClipper(isFirst: true),
        child: Material(
          elevation: selected ? 2 : 0,
          shadowColor: Colors.black45,
          color: transparent,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: selected ? unselectedHeaderColor : selectedHeaderColor,
              border: Border(bottom: BorderSide(color: selected ? transparent : tileOrFontColor, width: 1)),
            ),
            alignment: Alignment.centerLeft,
            child: HighlightText(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? borderColor : white, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTableRows(List<TopPlayerExposureData> topPlayers) {
    const int rowCount = 5;
    List<Widget> rows = [];

    for (int i = 0; i < rowCount; i++) {
      final bool hasLeft = i < topPlayers.length;
      final leftPlayer = hasLeft ? topPlayers[i] : null;

      final int rightIndex = i + rowCount;
      final bool hasRight = rightIndex < topPlayers.length;
      final rightPlayer = hasRight ? topPlayers[rightIndex] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: PlayerDataRow(index: i, player: leftPlayer, hasData: hasLeft, showRightBorder: true, exposureColor: red, selectedTabIndex: selectedTabIndex),
            ),
            Expanded(
              flex: 1,
              child: PlayerDataRow(index: rightIndex, player: rightPlayer, hasData: hasRight, showRightBorder: false, exposureColor: green, selectedTabIndex: selectedTabIndex),
            ),
          ],
        ),
      );
    }
    return rows;
  }
}

class TableHeader extends StatelessWidget {
  final int selectedTabIndex;

  const TableHeader({super.key, required this.selectedTabIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      color: Color(0xFFCED5DA),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Left Column Header
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(flex: 2, child: HeaderCell(title: 'UID', alignLeft: true)),
                Expanded(
                  flex: 1,
                  child: HeaderCell(title: 'Exposure', showIcon: selectedTabIndex == 1, alignRight: true),
                ),
                wb8,
                Expanded(
                  flex: 1,
                  child: HeaderCell(title: 'Matched Amount', showIcon: selectedTabIndex == 0, alignRight: true),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right Column Header
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(flex: 2, child: HeaderCell(title: 'UID', alignLeft: true)),
                Expanded(
                  flex: 1,
                  child: HeaderCell(title: 'Exposure', showIcon: selectedTabIndex == 1, alignRight: true),
                ),
                wb8,
                Expanded(
                  flex: 1,
                  child: HeaderCell(title: 'Matched Amount', showIcon: selectedTabIndex == 0, alignRight: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderCell extends StatelessWidget {
  final String title;
  final bool showIcon;
  final bool alignLeft;
  final bool alignRight;

  const HeaderCell({super.key, required this.title, this.showIcon = false, this.alignLeft = false, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : (alignRight ? Alignment.centerRight : Alignment.center),
      child: Row(
        children: [
          Expanded(
            child: HighlightText(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignRight ? TextAlign.right : (alignLeft ? TextAlign.left : TextAlign.center),
              style: const TextStyle(color: black, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          if (showIcon) const Icon(Icons.arrow_drop_down, size: 16, color: black),
        ],
      ),
    );
  }
}

class PlayerDataRow extends StatelessWidget {
  final TopPlayerExposureData? player;
  final bool hasData;
  final bool showRightBorder;
  final Color exposureColor;
  final int index;
  final int selectedTabIndex;

  const PlayerDataRow({
    super.key,
    required this.player,
    required this.hasData,
    required this.showRightBorder,
    required this.exposureColor,
    required this.index,
    required this.selectedTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hasData
          ? () {
              final baseUrl = html.window.location.origin;
              final storageKey = 'user-report-upline-${player!.userName}';
              final uplineJson = jsonEncode(player!.upline.map((u) => {'name': u.name, 'title': u.title}).toList());
              html.window.localStorage[storageKey] = uplineJson;
              final url = '$baseUrl${RoutePaths.manageUserReport}?userName=${eqc(player!.userName)}';
              html.window.open(url, '_blank', 'width=1200,height=850,resizable=yes,scrollbars=yes,menubar=no,toolbar=no,location=no,status=no');
            }
          : null,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  HighlightText(
                    hasData ? "${index + 1}." : '',
                    style: const TextStyle(color: black, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HighlightText(
                      hasData ? player!.userName : '',
                      style: const TextStyle(color: blue, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: HighlightText(
                hasData ? "(${formattedAmounts(player?.exposure ?? 0.0)})" : '',
                style: const TextStyle(color: red, fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            wb8,
            Expanded(
              flex: 1,
              child: HighlightText(
                hasData ? formattedAmounts(player!.balance) : '',
                style: const TextStyle(color: black, fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
