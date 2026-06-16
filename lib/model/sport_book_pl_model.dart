import 'package:flutter/material.dart';

import '../reusable/colors.dart';
import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/highlighted_text_widget.dart';

class SportBookPlResponse {
  final List<SportBookPlModel> data;
  final int page;
  final int pageSize;
  final double totalPl;
  final String status;
  final String message;
  final int totalPages;
  final int totalRecords;

  SportBookPlResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalPl,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
    required this.message,
  });

  factory SportBookPlResponse.fromJson(Map<dynamic, dynamic> json) {
    return SportBookPlResponse(
      data: (json['data'] as List? ?? []).map((e) => SportBookPlModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPl: _parseDouble(json['result']),
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class SportBookPlModel {
  final String eventID;
  final String eventName;
  final String eventTypeName;
  final String marketID;
  final String marketName;
  final double pl;
  final String settledDate;
  final String startTime;
  final SportBookPlDetailsGroup details;

  SportBookPlModel({
    required this.eventID,
    required this.eventName,
    required this.eventTypeName,
    required this.marketID,
    required this.marketName,
    required this.pl,
    required this.settledDate,
    required this.startTime,
    required this.details,
  });

  factory SportBookPlModel.fromJson(Map<String, dynamic> json) {
    return SportBookPlModel(
      eventID: json['eventID']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      eventTypeName: json['eventTypeName']?.toString() ?? '',
      marketID: json['marketID']?.toString() ?? '',
      marketName: json['marketName']?.toString() ?? '',
      pl: _parseDouble(json['pl']),
      settledDate: json['settledDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      details: SportBookPlDetailsGroup.fromJson(json['details'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SportBookPlDetailsGroup {
  final List<SportBookPlDetails> orders;
  final double totalBack;
  final double total;
  final double totalStack;

  SportBookPlDetailsGroup({
    required this.orders,
    required this.totalBack,
    required this.total,
    required this.totalStack,
  });

  double get totalStakes => orders.fold(0.0, (sum, order) => sum + order.debitAmount);
  double get netMarketTotal => total;

  factory SportBookPlDetailsGroup.fromJson(Map<String, dynamic> json) {
    return SportBookPlDetailsGroup(
      orders: (json['orders'] as List? ?? []).map((e) => SportBookPlDetails.fromJson(e as Map<String, dynamic>)).toList(),
      totalBack: _parseDouble(json['totalBack']),
      total: _parseDouble(json['total']),
      totalStack: _parseDouble(json['totalStack']),
    );
  }
}

class SportBookPlDetails {
  final double id;
  final String runnerName;
  final double odds;
  final double debitAmount;
  final String runnerType;
  final String createdDate;
  final String requestType;
  final double creditAmount;
  SportBookPlDetails({
    required this.id,
    required this.createdDate,
    required this.runnerName,
    required this.debitAmount,
    required this.odds,
    required this.runnerType,
    required this.creditAmount,
    required this.requestType,
  });

  factory SportBookPlDetails.fromJson(Map<String, dynamic> json) {
    return SportBookPlDetails(
      id: _parseDouble(json['id']),
      createdDate: json['createdDate']?.toString() ?? '',
      runnerName: json['runnerName']?.toString() ?? '',
      debitAmount: _parseDouble(json['debitAmount']),
      odds: _parseDouble(json['odds']),
      runnerType: json['runnerType']?.toString() ?? '',
      creditAmount: _parseDouble(json['creditAmount']),
      requestType: json['requestType']?.toString() ?? '',
    );
  }
  double get pnl => requestType.toLowerCase() == 'voided' ? 0 : creditAmount - debitAmount;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

List<TableColumn<SportBookPlModel>> sportBookPlColumns({
  required void Function(SportBookPlModel) onTap,
  required bool Function(SportBookPlModel) isExpanded,
}) {
  return [
    TableColumn<SportBookPlModel>(
      label: 'Market',
      flex: 4,
      customCell: (bet) => HighlightText.rich(
        bet.eventName,
        textDirection: TextDirection.ltr,
        textSpan: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(text: 'S/R ${bet.eventTypeName.toUpperCase()}'),
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
            TextSpan(text: bet.marketName),
          ],
        ),
      ),
    ),
    TableColumn<SportBookPlModel>(
      label: 'Start Time',
      flex: 1,
      value: (bet) => formattedDate(bet.startTime),
      alignRight: true,
    ),
    TableColumn<SportBookPlModel>(
      label: 'Settle Date',
      flex: 1,
      value: (bet) => formattedDate(bet.settledDate),
      alignRight: true,
    ),
    TableColumn<SportBookPlModel>(
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
