import 'package:intl/intl.dart';

import '../reusable/normal_pagination_table.dart';

class SettleHistoryResponse {
  final int status;
  final List<SettleHistoryData> data;
  final String message;

  SettleHistoryResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory SettleHistoryResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<SettleHistoryData> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => SettleHistoryData.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return SettleHistoryResponse(
      status: json['status'] as int? ?? 0,
      data: parsedData,
      message: json['message']?.toString() ?? '',
    );
  }
}

class SettleHistoryData {
  final int id;
  final String marketId;
  final int result;
  final String resultSource;
  final String updater;
  final String settleType;

  final int createdDate;
  final int updateDate;
  final int closeDate;

  final String operator;
  final String? message;

  final String eventId;
  final String eventType;
  final String eventName;
  final String marketName;

  SettleHistoryData({
    required this.id,
    required this.marketId,
    required this.result,
    required this.resultSource,
    required this.updater,
    required this.settleType,
    required this.createdDate,
    required this.updateDate,
    required this.closeDate,
    required this.operator,
    this.message,
    required this.eventId,
    required this.eventType,
    required this.eventName,
    required this.marketName,
  });

  factory SettleHistoryData.fromJson(Map<String, dynamic> json) {
    return SettleHistoryData(
      id: json['id'] ?? 0,
      marketId: json['marketId'] ?? '',
      result: json['result'] ?? 0,
      resultSource: json['resultSource'] ?? '',
      updater: json['updator'] ?? '',
      settleType: json['settleType'] ?? '',
      createdDate: json['createdDate'] ?? 0,
      updateDate: json['updateDate'] ?? 0,
      closeDate: json['closeDate'] ?? 0,
      operator: json['operator'] ?? '',
      message: json['message'],
      eventId: json['eventId'] ?? '',
      eventType: json['eventType'] ?? '',
      eventName: json['eventName'] ?? '',
      marketName: json['marketName'] ?? '',
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return "-";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(date);
  }

  String get createdDateUtcString => _formatDate(createdDate);

  String get updateDateUtcString => _formatDate(updateDate);

  String get closeDateUtcString => _formatDate(closeDate);
}

List<NormalTableColumn<SettleHistoryData>> marketSettleColumns = [
  NormalTableColumn(
    label: 'Event Type',
    value: (row) => row.eventType,
  ),
  NormalTableColumn(
    label: 'Event Id',
    value: (row) => row.eventId,
  ),
  NormalTableColumn(
    label: 'Event Name',
    width: 160,
    value: (row) => row.eventName,
  ),
  NormalTableColumn(
    label: 'Market Id',
    width: 140,
    value: (row) => row.marketId,
  ),
  NormalTableColumn(
    label: 'Market Name',
    width: 160,
    value: (row) => row.marketName,
  ),
  NormalTableColumn(
    label: 'Result',
    width: 100,
    value: (row) => row.result.toString(),
  ),
  NormalTableColumn(
    label: 'Settle Type',
    value: (row) => row.settleType,
  ),
  NormalTableColumn(
    flex: 1.5,
    label: 'Market Start Time',
    value: (row) => row.createdDateUtcString,
  ),
  NormalTableColumn(
    flex: 1.5,
    label: 'Market Update Time',
    value: (row) => row.updateDateUtcString,
  ),
  NormalTableColumn(
    flex: 1.5,
    label: 'Market Close Time',
    value: (row) => row.closeDateUtcString,
  ),
  NormalTableColumn(
    label: 'Updater',
    value: (row) => row.updater,
  ),
  NormalTableColumn(
    label: 'Operator',
    value: (row) => row.operator,
  ),
  NormalTableColumn(
    label: 'Message',
    value: (row) => row.message ?? '-',
  ),
];
