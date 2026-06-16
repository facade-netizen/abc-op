import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';

class IspIpLogsResponse {
  final List<IspIpLogsData> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  IspIpLogsResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory IspIpLogsResponse.fromJson(Map<dynamic, dynamic> json) {
    return IspIpLogsResponse(
      data: (json['data'] as List? ?? []).map((e) => IspIpLogsData.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class IspIpLogsData {
  final String loginTime;
  final String ip;
  final String isp;
  final String address;
  final String agent;
  final String userId;
  final String site;
  final String ssId;
  final String supId;
  final String maId;

  IspIpLogsData({
    required this.loginTime,
    required this.ip,
    required this.isp,
    required this.address,
    required this.agent,
    required this.userId,
    required this.site,
    required this.ssId,
    required this.supId,
    required this.maId,
  });

  factory IspIpLogsData.fromJson(Map<String, dynamic> json) {
    return IspIpLogsData(
      loginTime: json['loginTime']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      isp: json['isp']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      agent: json['agent']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      site: (json['site'] ?? '').toString().toUpperCase(),
      ssId: json['ssId']?.toString() ?? '',
      supId: json['supId']?.toString() ?? '',
      maId: json['maId']?.toString() ?? '',
    );
  }
}

List<TableColumn<IspIpLogsData>> ispIpLogColumns = [
  TableColumn(label: 'Site', value: (row) => row.site.toUpperCase()),
  TableColumn(label: 'SS', value: (row) => row.ssId),
  TableColumn(label: 'SUP', value: (row) => row.supId),
  TableColumn(label: 'MA', value: (row) => row.maId),
  TableColumn(label: 'PL', value: (row) => row.userId),
  TableColumn(label: 'Login Date & Time', value: (row) => formattedDate(row.loginTime)),
  TableColumn(label: 'IP Address', value: (row) => row.ip),
  TableColumn(label: 'ISP', value: (row) => row.isp),
  TableColumn(label: 'City/State/Country', value: (row) => row.address),
  TableColumn(label: 'User Agent Type', value: (row) => row.agent),
];
