import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';

class ChangePassLogsResponse {
  final List<ChangePassLogsData> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  ChangePassLogsResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory ChangePassLogsResponse.fromJson(Map<dynamic, dynamic> json) {
    return ChangePassLogsResponse(
      data: (json['data'] as List? ?? []).map((e) => ChangePassLogsData.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class ChangePassLogsData {
  final String createDate;
  final String ip;
  final String updator;
  final String site;

  ChangePassLogsData({required this.createDate, required this.ip, required this.site, required this.updator});

  factory ChangePassLogsData.fromJson(Map<String, dynamic> json) {
    return ChangePassLogsData(
      createDate: json['CreateDate']?.toString() ?? '',
      ip: json['IP']?.toString() ?? '',
      updator: json['Updater']?.toString() ?? '',
      site: (json['Site'] ?? '').toString().toUpperCase(),
    );
  }
}

List<TableColumn<ChangePassLogsData>> changePassLogColumns = [
  TableColumn(label: 'Date / Time', value: (row) => formattedDate(row.createDate)),
  TableColumn(label: 'IP Address', value: (row) => row.ip),
  TableColumn(label: 'Updator', value: (row) => row.updator),
  TableColumn(label: 'Site', value: (row) => row.site.toUpperCase()),
];
