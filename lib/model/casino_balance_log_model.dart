import '../reusable/colors.dart';
import '../reusable/formatters.dart';
import '../reusable/custom_table.dart';

class CasinoBalanceLogResponse {
  final List<CasinoBalanceLogModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  CasinoBalanceLogResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory CasinoBalanceLogResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<CasinoBalanceLogModel> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => CasinoBalanceLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return CasinoBalanceLogResponse(
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

class CasinoBalanceLogModel {
  final String createdDate;
  final String betType;
  final String eventName;
  final String marketName;
  final String marketId;
  final double debitAmount;
  final String eventId;
  final double creditAmount;
  final String userName;
  final String site;

  CasinoBalanceLogModel({
    required this.createdDate,
    required this.betType,
    required this.eventName,
    required this.marketName,
    required this.marketId,
    required this.debitAmount,
    required this.eventId,
    required this.creditAmount,
    required this.userName,
    required this.site,
  });

  factory CasinoBalanceLogModel.fromJson(Map<String, dynamic> json) {
    return CasinoBalanceLogModel(
      userName: json["userName"]?.toString() ?? "",
      site: (json['site'] ?? '').toString().toUpperCase(),
      eventId: json["eventId"]?.toString() ?? "",
      eventName: json["eventName"]?.toString() ?? "",
      marketId: json["marketId"]?.toString() ?? "",
      marketName: json["marketName"]?.toString() ?? "",
      betType: json["betType"]?.toString() ?? "",
      creditAmount: (json["creditAmount"] ?? 0.0).toDouble(),
      debitAmount: (json["debitAmount"] ?? 0.0).toDouble(),
      createdDate: json["createdDate"]?.toString() ?? "",
    );
  }
  double get netAmount => creditAmount - debitAmount;
}

List<TableColumn<CasinoBalanceLogModel>> casinoBalanceLogColumns = [
  TableColumn(alignCenter: true, label: 'UserId', flex: 80, value: (row) => row.userName),
  TableColumn(alignCenter: true, label: 'Site', flex: 90, value: (row) => row.site.toUpperCase()),
  TableColumn(alignCenter: true, label: 'EventId', flex: 80, value: (row) => row.eventId.isNotEmpty ? row.eventId : 'N/A'),
  TableColumn(alignCenter: true, label: 'EventName', flex: 200, value: (row) => row.eventName.isNotEmpty ? row.eventName : 'N/A'),
  TableColumn(alignCenter: true, label: 'MarketId', flex: 120, value: (row) => row.marketId.isNotEmpty ? row.marketId : 'N/A'),
  TableColumn(alignCenter: true, label: 'MarketName', flex: 120, value: (row) => row.marketName.isNotEmpty ? row.marketName : 'N/A'),
  TableColumn(flex: 120, alignCenter: true, label: 'Bet Type', value: (row) => row.betType.isNotEmpty ? row.betType : 'N/A'),
  TableColumn(alignCenter: true, label: 'Debit Amount', flex: 120, value: (row) => formattedAmounts(row.debitAmount), color: (row) => row.debitAmount >= 0 ? black : red),
  TableColumn(alignCenter: true, label: 'Credit Amount', flex: 120, value: (row) => formattedAmounts(row.creditAmount), color: (row) => row.creditAmount >= 0 ? black : red),
  TableColumn(flex: 120, alignCenter: true, label: 'Profit / Loss', value: (row) => formattedAmounts(row.netAmount), color: (row) => (row.netAmount) >= 0 ? black : red),
  TableColumn(alignCenter: true, label: 'Create Date', flex: 120, value: (row) => formattedDate(row.createdDate)),
];
