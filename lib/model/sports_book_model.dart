import 'package:flutter/material.dart';

import '../reusable/colors.dart';
import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/highlighted_text_widget.dart';

class SportsBookResponse {
  final List<SportsBookModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  SportsBookResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory SportsBookResponse.fromJson(Map<dynamic, dynamic> json) {
    return SportsBookResponse(
      data: (json['data'] as List? ?? []).map((e) => SportsBookModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class SportsBookModel {
  final int id;
  final String roundId;
  final String accountId;
  final String operatorId;
  final String operatorToken;
  final String createdDate;
  final String updatedDate;
  final String userName;
  final String site;
  final String betReqId;
  final String resultReqId;
  final String rollBackReqId;
  final String transactionId;
  final String gameId;
  final int rollbackAmount;
  final String betType;
  final String rollBackReason;
  final bool roundClosed;
  final String eventName;
  final String marketName;
  final String runnerName;
  final double exposure;
  final String marketId;
  final bool exposureEnabled;
  final double exposureTime;
  final String requestType;
  final String rollBackMessage;
  final double debitAmount;
  final String eventId;
  final double eventDate;
  final String eventStatus;
  final String competitionId;
  final String competitionName;
  final double odds;
  final String runnerType;
  final String selectionType;
  final String betfairEventId;
  final double creditAmount;
  final String gameName;

  SportsBookModel({
    required this.id,
    required this.roundId,
    required this.accountId,
    required this.operatorId,
    required this.operatorToken,
    required this.createdDate,
    required this.updatedDate,
    required this.userName,
    required this.site,
    required this.betReqId,
    required this.resultReqId,
    required this.rollBackReqId,
    required this.transactionId,
    required this.gameId,
    required this.rollbackAmount,
    required this.betType,
    required this.rollBackReason,
    required this.roundClosed,
    required this.eventName,
    required this.marketName,
    required this.runnerName,
    required this.exposure,
    required this.marketId,
    required this.exposureEnabled,
    required this.exposureTime,
    required this.requestType,
    required this.rollBackMessage,
    required this.debitAmount,
    required this.eventId,
    required this.eventDate,
    required this.eventStatus,
    required this.competitionId,
    required this.competitionName,
    required this.odds,
    required this.runnerType,
    required this.selectionType,
    required this.betfairEventId,
    required this.creditAmount,
    required this.gameName,
  });

  factory SportsBookModel.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> map = json ?? {};
    return SportsBookModel(
      id: _parseInt(map['id']),
      roundId: map['roundId']?.toString() ?? '',
      accountId: map['accountId']?.toString() ?? '',
      operatorId: map['operatorId']?.toString() ?? '',
      operatorToken: map['operatorToken']?.toString() ?? '',
      createdDate: map['createdDate']?.toString() ?? '',
      updatedDate: map['updatedDate']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      site: (map['site'] ?? '').toString().toUpperCase(),
      betReqId: map['betReqId']?.toString() ?? '',
      resultReqId: map['resultReqId']?.toString() ?? '',
      rollBackReqId: map['rollBackReqId']?.toString() ?? '',
      transactionId: map['transactionId']?.toString() ?? '',
      gameId: map['gameId']?.toString() ?? '',
      rollbackAmount: _parseInt(map['rollbackAmount']),
      betType: map['betType']?.toString() ?? '',
      rollBackReason: map['rollBackReason']?.toString() ?? '',
      roundClosed: map['roundClosed'] is bool ? map['roundClosed'] : map['roundClosed']?.toString().toLowerCase() == 'true',
      eventName: map['eventName']?.toString() ?? '',
      marketName: map['marketName']?.toString() ?? '',
      runnerName: map['runnerName']?.toString() ?? '',
      exposure: _parseDouble(map['exposure']),
      marketId: map['marketId']?.toString() ?? '',
      exposureEnabled: map['exposureEnabled'] is bool ? map['exposureEnabled'] : map['exposureEnabled']?.toString().toLowerCase() == 'true',
      exposureTime: _parseDouble(map['exposureTime']),
      requestType: map['requestType']?.toString() ?? '',
      rollBackMessage: map['rollBackMessage']?.toString() ?? '',
      debitAmount: _parseDouble(map['debitAmount']),
      eventId: map['eventId']?.toString() ?? '',
      eventDate: _parseDouble(map['eventDate']),
      eventStatus: map['eventStatus']?.toString() ?? '',
      competitionId: map['competitionId']?.toString() ?? '',
      competitionName: map['competitionName']?.toString() ?? '',
      odds: _parseDouble(map['odds']),
      runnerType: map['runnerType']?.toString() ?? '',
      selectionType: map['selectionType']?.toString() ?? '',
      betfairEventId: map['betfairEventId']?.toString() ?? '',
      creditAmount: _parseDouble(map['creditAmount']),
      gameName: map['gameName']?.toString() ?? '',
    );
  }
  double get pnl => creditAmount - debitAmount;

  /// Get the status of the bet
  String get status {
    if (resultReqId.isNotEmpty && requestType != "VOIDED") {
      return "Settled";
    } else if (requestType == "VOIDED") {
      return "Voided";
    } else {
      return "Not Settled";
    }
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

List<TableColumn<SportsBookModel>> sbBalanceLogColumns = [
  TableColumn(alignCenter: true, label: 'UserId', flex: 80, value: (row) => row.userName),
  TableColumn(alignCenter: true, label: 'Site', flex: 80, value: (row) => row.site.toUpperCase()),
  TableColumn(alignCenter: true, label: 'EventId', flex: 80, value: (row) => row.eventId.isNotEmpty ? row.eventId : 'N/A'),
  TableColumn(alignCenter: true, label: 'EventName', flex: 200, value: (row) => row.eventName.isNotEmpty ? row.eventName : 'N/A'),
  TableColumn(alignCenter: true, label: 'MarketId', flex: 120, value: (row) => row.marketId.isNotEmpty ? row.marketId : 'N/A'),
  TableColumn(alignCenter: true, label: 'MarketName', flex: 120, value: (row) => row.marketName.isNotEmpty ? row.marketName : 'N/A'),
  TableColumn(flex: 120, alignCenter: true, label: 'Game Type', value: (row) => row.gameName.isNotEmpty ? "S/R ${row.gameName}" : 'N/A'),
  TableColumn(alignCenter: true, label: 'Debit Amount', flex: 120, value: (row) => formattedAmounts(row.debitAmount), color: (row) => row.debitAmount >= 0 ? black : red),
  TableColumn(alignCenter: true, label: 'Credit Amount', flex: 120, value: (row) => formattedAmounts(row.creditAmount), color: (row) => row.creditAmount >= 0 ? black : red),
  TableColumn(flex: 120, alignCenter: true, label: 'Profit / Loss', value: (row) => formattedAmounts(row.pnl), color: (row) => (row.pnl) >= 0 ? black : red),
  TableColumn(alignCenter: true, label: 'Create Date', flex: 120, value: (row) => formattedDate(row.createdDate)),
];

List<TableColumn<SportsBookModel>> spForBettingHistory({void Function(SportsBookModel)? onTap, bool Function(SportsBookModel)? isExpanded}) {
  return [
    TableColumn<SportsBookModel>(
      label: 'Bet ID',
      flex: 10,
      customCell: (bet) {
        return HighlightText.rich(
          bet.betReqId,
          textDirection: TextDirection.ltr,
          textSpan: TextSpan(
            style: const TextStyle(fontSize: 13, color: primary),
            children: [
              if (bet.status != 'Voided')
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
              TextSpan(text: bet.id.toString()),
            ],
          ),
        );
      },
    ),
    TableColumn<SportsBookModel>(label: 'PL ID', flex: 10, value: (row) => row.userName.isNotEmpty ? row.userName : 'N/A'),
    TableColumn<SportsBookModel>(label: 'Site', flex: 12, value: (row) => row.site.toUpperCase()),
    TableColumn<SportsBookModel>(
      label: 'Market',
      flex: 32,
      customCell: (bet) => HighlightText.rich(
        bet.eventName,
        textDirection: TextDirection.ltr,
        textSpan: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.25, fontWeight: FontWeight.w400, color: Colors.black),
          children: [
            TextSpan(text: 'S/R ${bet.gameName.toUpperCase()}'),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
            ),
            TextSpan(
              text: bet.eventName,
              style: const TextStyle(fontSize: 12, height: 1.25, fontWeight: FontWeight.w700),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_right, size: 20, color: arrowColor),
              ),
            ),
            TextSpan(text: bet.marketName),
          ],
        ),
      ),
    ),
    TableColumn<SportsBookModel>(alignRight: true, label: 'Selection', flex: 16, value: (row) => row.runnerName.isNotEmpty ? row.runnerName : 'N/A'),
    TableColumn<SportsBookModel>(
      alignRight: true,
      label: 'Type',
      flex: 5,
      value: (row) => row.runnerType.toLowerCase() == 'back' ? 'Back' : 'Lay',
      color: (row) => row.runnerType.toLowerCase() == 'back' ? backType : layType,
    ),
    TableColumn<SportsBookModel>(alignRight: true, label: 'Bet placed', flex: 12, value: (row) => formatDateString(row.createdDate)),
    TableColumn<SportsBookModel>(alignRight: true, label: 'Odds req.', flex: 10, value: (row) => row.odds == 0 ? '-' : formattedAmounts(row.odds)),
    TableColumn<SportsBookModel>(alignRight: true, label: 'Stake', flex: 10, value: (row) => row.debitAmount == 0 ? '-' : formattedAmounts(row.debitAmount)),
    TableColumn<SportsBookModel>(
      alignRight: true,
      label: 'Avg. odds matched',
      flex: 10,
      value: (row) => row.odds == 0 || row.status == 'Voided' ? '-' : formattedAmounts(row.odds),
    ),
    TableColumn<SportsBookModel>(
      alignRight: true,
      label: 'Profit/Loss',
      flex: 10,
      value: (row) {
        final bool settled = row.status == 'Settled';
        final String title = settled ? formattedAmounts(row.pnl) : row.status;
        return title;
      },
      color: (row) => row.status != 'Settled'
          ? black
          : row.pnl >= 0
          ? black
          : red,
    ),
  ];
}

List<TableColumn<SportsBookModel>> sbPlColumns({required void Function(SportsBookModel) onTap, required bool Function(SportsBookModel) isExpanded}) {
  return [
    TableColumn<SportsBookModel>(
      label: 'Event',
      flex: 4,
      customCell: (bet) => HighlightText.rich(
        bet.eventName,
        textDirection: TextDirection.ltr,
        textSpan: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(text: 'S/R ${bet.gameName.toUpperCase()}'),
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
    TableColumn<SportsBookModel>(label: 'Created Date', flex: 1, value: (bet) => formatDateString(bet.createdDate), alignRight: true),
    TableColumn<SportsBookModel>(label: 'Updated Date', flex: 1, value: (bet) => formatDateString(bet.updatedDate), alignRight: true),
    TableColumn<SportsBookModel>(
      label: 'P/L',
      flex: 1,
      customCell: (bet) => InkWell(
        onTap: () => onTap(bet),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HighlightText(
              formattedAmounts(bet.pnl),
              style: TextStyle(overflow: TextOverflow.ellipsis, color: bet.pnl < 0 ? red : black),
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
