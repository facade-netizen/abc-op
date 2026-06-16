import 'package:flutter/material.dart';

import '../reusable/colors.dart';
import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/highlighted_text_widget.dart';

class BetResponse {
  final List<BetData> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  BetResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory BetResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<BetData> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => BetData.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return BetResponse(
      data: parsedData,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class BetData {
  final String ssid;
  final String supid;
  final String maId;
  final String plId;
  final int betId;
  final String betTaken;
  final String ip;
  final String isp;
  final String event;
  final String sport;
  final String marketName;
  final String runner;
  final String mode;
  final String type;
  final double orderPrice;
  final double stack;
  final String liability;
  final double pnl;
  final String currency;
  final String wlName;
  final double unMatchedPrice;
  final double matchedPrice;
  final double oddDiff;
  final bool isDone;
  BettingType bettingType;
  final String line;
  final String status;
  final double exposure;

  BetData({
    required this.bettingType,
    required this.ssid,
    required this.supid,
    required this.maId,
    required this.plId,
    required this.betId,
    required this.betTaken,
    required this.ip,
    required this.isp,
    required this.event,
    required this.runner,
    required this.sport,
    required this.marketName,
    required this.mode,
    required this.type,
    required this.orderPrice,
    required this.stack,
    required this.liability,
    required this.pnl,
    required this.currency,
    required this.wlName,
    required this.unMatchedPrice,
    required this.matchedPrice,
    required this.oddDiff,
    required this.isDone,
    required this.line,
    required this.status,
    required this.exposure,
  });

  factory BetData.fromJson(Map<String, dynamic> json) {
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
    return BetData(
      bettingType: bettingTypeValue(json['bettingType'] ?? 0),
      ssid: json['ssid'] ?? '',
      supid: json['supid'] ?? '',
      maId: json['maId'] ?? '',
      plId: json['plId'] ?? '',
      betId: json['betId'] ?? 0,
      betTaken: json['betTaken'] ?? '',
      ip: json['ip'] ?? '-',
      isp: json['isp'] ?? '-',
      event: json['event'] ?? '',
      runner: json['runner'] ?? '',
      sport: json['sport'] ?? '',
      marketName: json['marketName'] ?? '',
      mode: json['mode'] ?? '',
      type: json['type'] ?? '',
      orderPrice: json['orderPrice'] ?? 0.0,
      stack: json['stack'] ?? 0.0,
      liability: json['liability'] ?? '-',
      pnl: json['pnl'] ?? 0,
      currency: json['currency'] ?? '',
      wlName: (json['wlName'] ?? '').toUpperCase(),
      unMatchedPrice: json['unMatchedPrice'] ?? 0.0,
      matchedPrice: json['matchedPrice'] ?? 0.0,
      oddDiff: json['oddDiff'] ?? 0.0,
      isDone: json['isDone'] ?? false,
      line: parsedLine,
      status: json['status'] ?? '',
      exposure: json['exposure'] ?? 0.0,
    );
  }
}

enum BettingType { odds, line, bookmaker }

BettingType bettingTypeValue(int value) {
  switch (value) {
    case 0:
      return BettingType.odds;
    case 1:
      return BettingType.line;
    case 2:
      return BettingType.bookmaker;
    default:
      return BettingType.odds;
  }
}

String bettingTypeName(BettingType type) {
  switch (type) {
    case BettingType.odds:
      return 'Match Odds';
    case BettingType.line:
      return 'FANCY_BET';
    case BettingType.bookmaker:
      return 'Bookmaker';
  }
}

List<TableColumn<BetData>> betDataColumns = [
  TableColumn(
    label: 'SS ID',
    flex: 120,
    value: (row) => row.ssid,
  ),
  TableColumn(
    label: 'SUP ID',
    flex: 100,
    value: (row) => row.supid,
  ),
  TableColumn(
    label: 'MA ID',
    flex: 100,
    value: (row) => row.maId,
  ),
  TableColumn(
    label: 'PL ID',
    flex: 100,
    value: (row) => row.plId,
  ),
  TableColumn(
    label: 'Bet ID',
    flex: 100,
    color: (row) => primary,
    value: (row) => row.betId.toString(),
  ),
  TableColumn(
    label: 'Bet Taken',
    flex: 100,
    value: (row) => formattedDate(row.betTaken),
  ),
  TableColumn(
    flex: 110,
    label: 'IP Address',
    value: (row) => row.ip,
  ),
  TableColumn(
    label: 'ISP',
    flex: 100,
    value: (row) => row.isp,
  ),
  TableColumn(
    label: 'Market',
    flex: 120,
    customCell: (row) {
      return HighlightText.rich(
        row.event,
        textSpan: TextSpan(
          style: TextStyle(
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: row.sport.toUpperCase(),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(
              text: row.event,
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(
              text: bettingTypeName(row.bettingType),
            ),
          ],
        ),
      );
    },
  ),
  TableColumn(
    label: 'Selection',
    flex: 90,
    color: (row) => primary,
    value: (row) => row.bettingType == BettingType.line ? row.marketName : row.runner,
  ),
  TableColumn(
    label: 'Type',
    flex: 60,
    value: (row) => row.type.toLowerCase().contains('back') ? 'Back' : 'Lay',
    color: (row) => row.type.toLowerCase().contains('back') ? primary : layBtn,
  ),
  TableColumn(
    label: 'Odds Req.',
    flex: 100,
    value: (row) => row.bettingType == BettingType.line ? '${row.line.isNotEmpty && row.line != '-' ? '${row.line} /' : ''} ${row.orderPrice}' : formattedAmounts(row.orderPrice),
  ),
  TableColumn(
    label: 'Stake',
    flex: 80,
    alignRight: true,
    value: (row) => formattedAmounts(row.stack),
  ),
  TableColumn(
    flex: 80,
    label: 'Liability',
    alignRight: true,
    value: (row) => formattedAmounts(row.exposure),
    color: (row) => row.exposure >= 0 ? black : red,
  ),
  TableColumn(
    flex: 100,
    label: 'Profit / Loss',
    alignRight: true,
    value: (row) => switch (row.status.toLowerCase()) {
      'void' => 'Voided',
      'new' => 'Not Settled',
      _ => formattedAmounts(row.pnl),
    },
    color: (row) => ['void', 'new'].contains(row.status.toLowerCase()) || row.pnl >= 0 ? black : red,
  ),
  TableColumn(
    flex: 110,
    label: 'Site',
    value: (row) => row.wlName,
  ),
  TableColumn(
    flex: 90,
    label: 'UnMatchedLastPrice',
    alignRight: true,
    value: (row) => formattedAmounts(row.unMatchedPrice),
  ),
  TableColumn(
    flex: 80,
    label: 'MatchedLastPrice',
    alignRight: true,
    value: (row) => formattedAmounts(row.matchedPrice),
  ),
  TableColumn(
    flex: 80,
    label: 'OddsDifferential',
    alignRight: true,
    value: (row) => formatOddDiff(row.oddDiff),
  ),
];

String formatOddDiff(double value) {
  final absValue = value.abs().toStringAsFixed(2);
  final formattedValue = value < 0 ? '-$absValue' : absValue;
  return '$formattedValue%';
}

List<TableColumn<BetData>> sbBetDataColumns({bool showResult = false}) {
  return [
    TableColumn(
      label: 'SS ID',
      flex: 120,
      value: (row) => row.ssid,
    ),
    TableColumn(
      label: 'SUP ID',
      flex: 100,
      value: (row) => row.supid,
    ),
    TableColumn(
      label: 'MA ID',
      flex: 100,
      value: (row) => row.maId,
    ),
    TableColumn(
      label: 'PL ID',
      flex: 100,
      value: (row) => row.plId,
    ),
    TableColumn(
      label: 'Bet ID',
      flex: 100,
      color: (row) => primary,
      value: (row) => row.betId.toString(),
    ),
    TableColumn(
      label: 'Bet Taken',
      flex: 100,
      value: (row) => formattedDate(row.betTaken),
    ),
    TableColumn(
      flex: 110,
      label: 'IP Address',
      value: (row) => row.ip,
    ),
    TableColumn(
      label: 'ISP',
      flex: 100,
      value: (row) => row.isp,
    ),
    TableColumn(
      label: 'Market',
      flex: 120,
      customCell: (row) {
        return HighlightText.rich(
          row.event,
          textSpan: TextSpan(
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "S/R ${row.sport.toUpperCase()}",
              ),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
              TextSpan(
                text: row.event,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
              TextSpan(
                text: row.marketName,
              ),
            ],
          ),
        );
      },
    ),
    TableColumn(
      label: 'Selection',
      flex: 90,
      color: (row) => primary,
      value: (row) => row.runner,
    ),
    TableColumn(
      label: 'Type',
      flex: 60,
      value: (row) => row.type.toLowerCase().contains('back') ? 'Back' : 'Lay',
      color: (row) => row.type.toLowerCase().contains('back') ? primary : layBtn,
    ),
    TableColumn(
      label: 'Odds Req.',
      flex: 100,
      value: (row) => row.bettingType == BettingType.line ? '${row.line.isNotEmpty && row.line != '-' ? '${row.line} /' : ''} ${row.orderPrice}' : formattedAmounts(row.orderPrice),
    ),
    TableColumn(
      label: 'Stake',
      flex: 80,
      alignRight: true,
      value: (row) => formattedAmounts(row.stack),
    ),
    TableColumn(
      flex: 80,
      label: 'Liability',
      alignRight: true,
      value: (row) => formattedAmounts(row.exposure),
      color: (row) => row.exposure >= 0 ? black : red,
    ),
    if (showResult)
      TableColumn(
        flex: 70,
        label: 'Result',
        alignRight: true,
        value: (row) => row.status.toLowerCase() == 'filled' ? (row.pnl >= 0 ? 'WIN' : 'LOSS') : '',
      ),
    TableColumn(
      flex: 100,
      label: 'Profit / Loss',
      alignRight: true,
      value: (row) => switch (row.status.toLowerCase()) {
        'void' => 'Voided',
        'open' => 'Not Settled',
        _ => formattedAmounts(row.pnl),
      },
      color: (row) => ['void', 'open'].contains(row.status.toLowerCase()) || row.pnl >= 0 ? black : red,
    ),
    TableColumn(
      flex: 110,
      label: 'Site',
      value: (row) => row.wlName,
    ),
    TableColumn(
      flex: 90,
      label: 'UnMatchedLastPrice',
      alignRight: true,
      value: (row) => formattedAmounts(row.unMatchedPrice),
    ),
    TableColumn(
      flex: 80,
      label: 'MatchedLastPrice',
      alignRight: true,
      value: (row) => formattedAmounts(row.matchedPrice),
    ),
    TableColumn(
      flex: 80,
      label: 'OddsDifferential',
      alignRight: true,
      value: (row) => formatOddDiff(row.oddDiff),
    ),
  ];
}

List<TableColumn<BetData>> betListLiveColumns(bool isSportsBook) {
  return [
    TableColumn(
      label: 'SS ID',
      flex: 120,
      value: (row) => row.ssid,
    ),
    TableColumn(
      label: 'SUP ID',
      flex: 100,
      value: (row) => row.supid,
    ),
    TableColumn(
      label: 'MA ID',
      flex: 100,
      value: (row) => row.maId,
    ),
    TableColumn(
      label: 'PL ID',
      flex: 100,
      value: (row) => row.plId,
    ),
    TableColumn(
      label: 'Bet ID',
      flex: 100,
      color: (row) => primary,
      value: (row) => row.betId.toString(),
    ),
    TableColumn(
      label: 'Bet Taken',
      flex: 100,
      value: (row) => formattedDate(row.betTaken),
    ),
    TableColumn(
      flex: 110,
      label: 'IP Address',
      value: (row) => row.ip,
    ),
    TableColumn(
      label: 'ISP',
      flex: 100,
      value: (row) => row.isp,
    ),
    TableColumn(
      label: 'Market',
      flex: 120,
      customCell: (row) {
        return HighlightText.rich(
          row.event,
          textSpan: TextSpan(
            style: TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "${isSportsBook ? 'S/R' : ''} ${row.sport.toUpperCase()}",
              ),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
              TextSpan(
                text: row.event,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
              TextSpan(
                text: isSportsBook ? row.marketName : bettingTypeName(row.bettingType),
              ),
            ],
          ),
        );
      },
    ),
    TableColumn(
      label: 'Selection',
      flex: 90,
      color: (row) => primary,
      value: (row) => isSportsBook
          ? row.runner
          : row.bettingType == BettingType.line
              ? row.marketName
              : row.runner,
    ),
    TableColumn(
      label: 'Type',
      flex: 60,
      value: (row) {
        final bool isBack = row.type.toLowerCase().contains('back');
        return row.bettingType == BettingType.line ? (isBack ? 'Yes' : 'No') : (isBack ? 'Back' : 'Lay');
      },
      color: (row) => row.type.toLowerCase().contains('back') ? primary : layBtn,
    ),
    TableColumn(
      label: 'Odds Req.',
      flex: 100,
      value: (row) => row.bettingType == BettingType.line ? '${row.line.isNotEmpty && row.line != '-' ? '${row.line} /' : ''} ${row.orderPrice}' : formattedAmounts(row.orderPrice),
    ),
    TableColumn(
      label: 'Stake',
      flex: 80,
      alignRight: true,
      value: (row) => formattedAmounts(row.stack),
    ),
    TableColumn(
      flex: 80,
      label: 'Liability',
      alignRight: true,
      value: (row) => row.exposure == 0 ? '-' : formattedAmounts(row.exposure),
      color: (row) => row.exposure >= 0 ? black : red,
    ),
    TableColumn(
      flex: 100,
      label: 'Result',
      alignRight: true,
      value: (row) => row.status.toLowerCase() == 'filled' ? (row.pnl >= 0 ? 'WIN' : 'LOSS') : '',
    ),
    TableColumn(
      flex: 110,
      label: 'Site',
      value: (row) => row.wlName,
    ),
    TableColumn(
      flex: 90,
      label: 'UnMatchedLastPrice',
      alignRight: true,
      value: (row) => formattedAmounts(row.unMatchedPrice),
    ),
    TableColumn(
      flex: 80,
      label: 'MatchedLastPrice',
      alignRight: true,
      value: (row) => formattedAmounts(row.matchedPrice),
    ),
    TableColumn(
      flex: 80,
      label: 'OddsDifferential',
      alignRight: true,
      value: (row) => formatOddDiff(row.oddDiff),
    ),
  ];
}
