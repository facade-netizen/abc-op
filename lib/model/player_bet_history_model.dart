import 'package:flutter/material.dart';

import '../reusable/colors.dart';
import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/highlighted_text_widget.dart';
import '../reusable/normal_pagination_table.dart';
import 'bet_list_model.dart';

class PlayerBetHistoryResponse {
  final String status;
  final List<PlayerBetHistory> data;
  final String message;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalRecords;

  PlayerBetHistoryResponse({
    required this.status,
    required this.data,
    required this.message,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
  });

  factory PlayerBetHistoryResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<PlayerBetHistory> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => PlayerBetHistory.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return PlayerBetHistoryResponse(
      data: parsedData,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class PlayerBetHistory {
  final int orderId;
  final String sportName;
  final BettingType bettingType;
  final String marketId;
  final String userId;
  final String site;
  final String userName;
  final String competitionId;
  final String eventId;
  final String runnerID;
  final double stake;
  final double price;
  final String side;
  final String timeStamp;
  final String updatedTime;
  final String status;
  final int sid;
  final double filledPrice;
  final String? rejectReason;
  final String ip;
  final String eventName;
  final String competitionName;
  final String runnerName;
  final int buildNumber;
  final String version;
  final String mode;
  final String platform;
  final double exposure;
  final double openBalance;
  final double closeBalance;
  final double mtm;
  final bool isDone;
  final String result;
  final String marketType;
  final String marketName;
  double liability;
  final String line;

  PlayerBetHistory({
    required this.sportName,
    required this.orderId,
    required this.bettingType,
    required this.marketId,
    required this.userId,
    required this.userName,
    required this.site,
    required this.competitionId,
    required this.eventId,
    required this.runnerID,
    required this.stake,
    required this.price,
    required this.side,
    required this.timeStamp,
    required this.updatedTime,
    required this.status,
    required this.sid,
    required this.filledPrice,
    required this.rejectReason,
    required this.ip,
    required this.eventName,
    required this.competitionName,
    required this.runnerName,
    required this.buildNumber,
    required this.version,
    required this.mode,
    required this.platform,
    required this.exposure,
    required this.mtm,
    required this.isDone,
    required this.result,
    required this.openBalance,
    required this.closeBalance,
    required this.marketType,
    required this.marketName,
    required this.liability,
    required this.line,
  });

  factory PlayerBetHistory.fromJson(Map<String, dynamic> json) {
    final bool isBack = json['side']?.toLowerCase().contains('back') ?? false;

    // Parse the line value based on isBack flag
    String parsedLine = '';
    final dynamic lineValue = json['line'];

    if (lineValue != null && lineValue.toString().isNotEmpty) {
      if (isBack) {
        // If isBack is true, take the first value before comma
        parsedLine = lineValue.toString().split(',').first;
      } else {
        // If isBack is false (lay bet), take the last value after comma
        final List<String> parts = lineValue.toString().split(',');
        parsedLine = parts.length > 1 ? parts.last : parts.first;
      }
    }

    return PlayerBetHistory(
      sportName: getSportName(json["sid"] is int ? json["sid"] : int.tryParse("${json["sid"]}") ?? 0).toUpperCase(),
      orderId: json["orderId"] is int ? json["orderId"] : int.tryParse("${json["orderId"]}") ?? 0,
      bettingType: bettingTypeValue(json['bettingType'] ?? 0),
      marketId: json["marketId"]?.toString() ?? "",
      userId: json["userId"]?.toString() ?? "",
      userName: json["userName"]?.toString() ?? "",
      site: (json['site'] ?? '').toString().toUpperCase(),
      marketType: json["marketType"]?.toString() ?? "",
      marketName: json["marketName"]?.toString() ?? "",
      competitionId: json["competitionId"]?.toString() ?? "",
      eventId: json["eventId"]?.toString() ?? "",
      runnerID: json["runnerID"]?.toString() ?? "",
      stake: (json["stake"] is num) ? (json["stake"] as num).toDouble() : 0.0,
      price: (json["price"] is num) ? (json["price"] as num).toDouble() : 0.0,
      side: json["side"]?.toString() ?? "",
      timeStamp: json["timeStamp"]?.toString() ?? "",
      updatedTime: json["updatedTime"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      sid: json["sid"] is int ? json["sid"] : int.tryParse("${json["sid"]}") ?? 0,
      filledPrice: (json["filledPrice"] is num) ? (json["filledPrice"] as num).toDouble() : 0.0,
      rejectReason: json["rejectReason"]?.toString(),
      ip: json["ip"]?.toString() ?? "",
      eventName: json["eventName"]?.toString() ?? "",
      competitionName: json["competitionName"]?.toString() ?? "",
      runnerName: json["runnerName"]?.toString() ?? "",
      buildNumber: json["buildNumber"] is int ? json["buildNumber"] : int.tryParse("${json["buildNumber"]}") ?? 0,
      version: json["version"]?.toString() ?? "",
      mode: json["mode"]?.toString() ?? "",
      platform: json["platform"]?.toString() ?? "",
      exposure: (json["exposure"] is num) ? (json["exposure"] as num).toDouble() : 0.0,
      openBalance: (json["openBalance"] is num) ? (json["openBalance"] as num).toDouble() : 0.0,
      closeBalance: (json["closeBalance"] is num) ? (json["closeBalance"] as num).toDouble() : 0.0,
      mtm: (json["mtm"] is num) ? (json["mtm"] as num).toDouble() : 0.0,
      isDone: json["isDone"] ?? false,
      result: json["result"]?.toString() ?? "",
      liability: (json["liability"] is num) ? (json["liability"] as num).toDouble() : 0.0,
      line: parsedLine,
    );
  }
}

String getSportName(int id) {
  switch (id) {
    case 4:
      return "Cricket";
    case 1:
      return "Soccer";
    case 2:
      return "Tennis";
    case 7:
      return "Horse Racing";
    case 4339:
      return "Greyhound Racing";
    case 2378961:
      return "Politics";
    default:
      return "Unknown";
  }
}

List<NormalTableColumn<PlayerBetHistory>> balanceLogColumns = [
  NormalTableColumn(alignCenter: true, flex: 120, label: 'UserId', value: (bet) => bet.userName),
  NormalTableColumn(alignCenter: true, label: 'Site', flex: 80, value: (bet) => bet.platform),
  NormalTableColumn(alignCenter: true, label: 'EventId', flex: 80, value: (bet) => bet.eventId),
  NormalTableColumn(alignCenter: true, label: 'EventName', flex: 200, value: (bet) => bet.eventName),
  NormalTableColumn(alignCenter: true, label: 'MarketId', flex: 120, value: (bet) => bet.marketId),
  NormalTableColumn(alignCenter: true, label: 'MarketName', flex: 120, value: (bet) => bet.runnerName),
  NormalTableColumn(flex: 120, alignCenter: true, label: 'Category Type', value: (bet) => bettingTypeName(bet.bettingType)),
  NormalTableColumn(
    alignCenter: true,
    label: 'Before Total Balance',
    flex: 120,
    value: (bet) => formattedAmounts(bet.openBalance),
    color: (bet) => bet.openBalance >= 0 ? black : red,
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'After Total Balance',
    flex: 120,
    value: (bet) => formattedAmounts(bet.closeBalance),
    color: (bet) => bet.closeBalance >= 0 ? black : red,
  ),
  NormalTableColumn(
    flex: 120,
    alignCenter: true,
    label: 'Profit / Loss',
    value: (bet) => formattedAmounts(bet.mtm),
    color: (bet) => bet.mtm > 0
        ? green
        : bet.mtm == 0
            ? black
            : red,
  ),
  NormalTableColumn(alignCenter: true, label: 'Status', flex: 120, value: (bet) => bet.status.toUpperCase()),
  NormalTableColumn(alignCenter: true, label: 'Create Date', flex: 120, value: (bet) => formattedDate(bet.timeStamp)),
];

///
List<TableColumn<PlayerBetHistory>> exchangeBettingHistory({void Function(PlayerBetHistory)? onTap, bool Function(PlayerBetHistory)? isExpanded}) {
  return [
    TableColumn<PlayerBetHistory>(
      label: 'Bet ID',
      flex: 10,
      customCell: (bet) {
        return HighlightText.rich(
          bet.orderId.toString(),
          textDirection: TextDirection.ltr,
          textSpan: TextSpan(
            style: const TextStyle(fontSize: 13, color: primary),
            children: [
              if (bet.status.toLowerCase() != 'void')
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () => onTap?.call(bet),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(isExpanded?.call(bet) == true ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined, size: 18, color: grey),
                    ),
                  ),
                ),
              TextSpan(text: bet.orderId.toString()),
            ],
          ),
        );
      },
    ),
    TableColumn<PlayerBetHistory>(label: 'PL ID', flex: 10, value: (bet) => bet.userName.isNotEmpty ? bet.userName : 'N/A'),
    TableColumn<PlayerBetHistory>(
      label: 'Market',
      flex: 20,
      customCell: (bet) => HighlightText.rich(
        bet.eventName,
        textDirection: TextDirection.ltr,
        textSpan: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.25, fontWeight: FontWeight.w400, color: Colors.black),
          children: [
            TextSpan(text: bet.sportName.toUpperCase()),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(
              text: bet.eventName,
              style: const TextStyle(fontSize: 12, height: 1.25, fontWeight: FontWeight.w700),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(text: bettingTypeName(bet.bettingType)),
          ],
        ),
      ),
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Selection',
      flex: 20,
      value: (bet) => bet.bettingType == BettingType.line ? bet.marketName : bet.runnerName,
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Type',
      flex: 5,
      value: (bet) {
        final bool isBack = bet.side.toLowerCase() == 'back';
        return bet.bettingType == BettingType.line ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay');
      },
      color: (bet) => bet.side.toLowerCase().contains('back') ? backType : layType,
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Bet placed',
      flex: 12,
      value: (bet) => formatDateString(bet.timeStamp),
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Odds req.',
      flex: 10,
      value: (bet) => bet.bettingType == BettingType.line ? '${bet.line}/${bet.price}' : formattedAmounts(bet.price),
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Stake',
      flex: 10,
      value: (bet) => formattedAmounts(bet.stake),
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Avg. odds matched',
      flex: 10,
      value: (bet) => bet.filledPrice == 0
          ? '-'
          : bet.bettingType == BettingType.line
              ? '${bet.line}/${bet.filledPrice}'
              : formattedAmounts(bet.filledPrice),
    ),
    TableColumn<PlayerBetHistory>(
      alignRight: true,
      label: 'Profit/Loss',
      flex: 10,
      value: (row) => switch (row.status.toLowerCase()) {
        'void' => 'Voided',
        'new' => 'Not Settled',
        _ => formattedAmounts(row.mtm),
      },
      color: (row) => ['void', 'new'].contains(row.status.toLowerCase()) || row.mtm >= 0 ? black : red,
    ),
  ];
}
