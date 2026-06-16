import 'package:flutter/material.dart';

import '../reusable/colors.dart';
import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/highlighted_text_widget.dart';

class PlayerProfitAndLossResponse {
  final List<PlayerProfitAndLossResponseResult> data;
  final int page;
  final int pageSize;
  final double totalPnl;
  final String status;
  final int totalPages;
  final int totalRecords;

  PlayerProfitAndLossResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalPnl,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory PlayerProfitAndLossResponse.fromJson(Map<dynamic, dynamic> json) {
    return PlayerProfitAndLossResponse(
      data: (json['data'] as List? ?? []).map((e) => PlayerProfitAndLossResponseResult.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPnl: (json['result'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class PlayerProfitAndLossResponseResult {
  final String eventTypeName;
  final String eventName;
  final String marketName;
  final String startTime;
  final String settledDate;
  final double pl;
  final ResultDetails? details;

  PlayerProfitAndLossResponseResult({
    required this.eventTypeName,
    required this.eventName,
    required this.marketName,
    required this.startTime,
    required this.settledDate,
    required this.pl,
    this.details,
  });

  factory PlayerProfitAndLossResponseResult.fromJson(Map<String, dynamic> json) {
    return PlayerProfitAndLossResponseResult(
      eventTypeName: json['eventTypeName'] ?? '',
      eventName: json['eventName'] ?? '',
      marketName: json['marketName'] ?? '',
      startTime: json['startTime'] ?? '',
      settledDate: json['settledDate'] ?? '',
      pl: (json['pl'] as num?)?.toDouble() ?? 0.0,
      details: json['details'] != null ? ResultDetails.fromJson(json['details'] as Map<String, dynamic>) : null,
    );
  }
}

class ResultDetails {
  final List<ResultBets> orders;
  final double totalBack;
  final double totalLay;
  final double total;
  final double totalStack;
  final double totalCommission;

  ResultDetails({required this.orders, required this.totalBack, required this.totalLay, required this.total, required this.totalStack, required this.totalCommission});

  factory ResultDetails.fromJson(Map<String, dynamic> json) {
    return ResultDetails(
      orders: (json['orders'] as List<dynamic>?)?.map((e) => ResultBets.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      totalBack: (json['totalBack'] as num?)?.toDouble() ?? 0.0,
      totalLay: (json['totalLay'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      totalStack: (json['totalStack'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ResultBets {
  final int orderId;
  final int bettingType;
  final double stake;
  final double price;
  final String side;
  final String result;
  final String timeStamp;
  final String runnerName;
  final String line;
  final double mtm;

  ResultBets({
    required this.orderId,
    required this.bettingType,
    required this.stake,
    required this.price,
    required this.side,
    required this.timeStamp,
    required this.runnerName,
    required this.line,
    required this.mtm,
    required this.result,
  });

  factory ResultBets.fromJson(Map<String, dynamic> json) {
    final bool isBack = json['side']?.toLowerCase().contains('back') ?? false;

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

    return ResultBets(
      orderId: json['orderId'] as int? ?? 0,
      bettingType: json['bettingType'] as int? ?? 0,
      stake: (json['stake'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      side: json['side'] ?? '',
      timeStamp: json['timeStamp'] ?? '',
      runnerName: json['runnerName'] ?? '',
      result: json['result'] ?? '',
      line: parsedLine,
      mtm: (json['status'] as String?)?.toLowerCase() == 'void' ? 0.0 : (json['mtm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

List<TableColumn<PlayerProfitAndLossResponseResult>> exchangePlColumns({
  required void Function(PlayerProfitAndLossResponseResult) onTap,
  required bool Function(PlayerProfitAndLossResponseResult) isExpanded,
}) {
  return [
    TableColumn<PlayerProfitAndLossResponseResult>(
      label: 'Market',
      flex: 4,
      customCell: (bet) => HighlightText.rich(
        bet.eventName,
        textDirection: TextDirection.ltr,
        textSpan: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(text: bet.eventTypeName.toUpperCase()),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(
              text: bet.eventName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
            ),
            TextSpan(text: bet.marketName.toLowerCase().contains('line') && bet.details != null ? bet.details?.orders.first.runnerName : bet.marketName),
          ],
        ),
      ),
    ),
    TableColumn<PlayerProfitAndLossResponseResult>(label: 'Start Time', flex: 1, value: (bet) => formattedDate(bet.startTime), alignRight: true),
    TableColumn<PlayerProfitAndLossResponseResult>(label: 'Settle Date', flex: 1, value: (bet) => formattedDate(bet.settledDate), alignRight: true),
    TableColumn<PlayerProfitAndLossResponseResult>(
      label: 'P/L',
      flex: 1,
      customCell: (bet) => InkWell(
        onTap: () => onTap(bet),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HighlightText(
              formattedAmounts(bet.pl),
              style: TextStyle(overflow: TextOverflow.ellipsis, color: bet.pl < 0 ? red : black),
            ),
            const SizedBox(width: 4),
            Icon(isExpanded(bet) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined, size: 18, color: grey),
          ],
        ),
      ),
      alignRight: true,
    ),
  ];
}
