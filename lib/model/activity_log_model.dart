import 'package:flutter/material.dart';

import '../reusable/custom_table.dart';
import '../reusable/formatters.dart';
import '../reusable/normal_pagination_table.dart';

/// Activity log model and response
class ActivityLogsResponse {
  final List<ActivityLogsData> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  ActivityLogsResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory ActivityLogsResponse.fromJson(Map<dynamic, dynamic> json) {
    final data = (json['data'] as List? ?? []).map((e) => ActivityLogsData.fromJson(e)).toList();
    final String latestValidIp = data.lastWhere((row) => row.hasValidIp, orElse: () => ActivityLogsData.empty()).ip;
    final String latestValidIsp = data.lastWhere((row) => row.hasValidIsp, orElse: () => ActivityLogsData.empty()).isp;
    final String latestValidAddress = data.lastWhere((row) => row.hasValidAddress, orElse: () => ActivityLogsData.empty()).address;
    final String latestValidAgent = data.lastWhere((row) => row.hasValidAgent, orElse: () => ActivityLogsData.empty()).agent;

    final sanitizedData = data.map((row) {
      return row.copyWith(
        ip: row.hasValidIp ? row.ip : latestValidIp,
        isp: row.hasValidIsp ? row.isp : latestValidIsp,
        address: row.hasValidAddress ? row.address : latestValidAddress,
        agent: row.hasValidAgent ? row.agent : latestValidAgent,
      );
    }).toList();

    return ActivityLogsResponse(
      data: sanitizedData,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class ActivityLogsData {
  final int id;
  final String loginTime;
  final String loginStatus;
  final String ip;
  final String isp;
  final String address;
  final String agent;
  final String userId;
  final String site;

  ActivityLogsData({
    required this.id,
    required this.loginTime,
    required this.loginStatus,
    required this.ip,
    required this.isp,
    required this.address,
    required this.agent,
    required this.userId,
    required this.site,
  });

  factory ActivityLogsData.fromJson(Map<String, dynamic> json) {
    return ActivityLogsData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      loginTime: json['loginTime']?.toString() ?? '',
      loginStatus: json['loginStatus']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      isp: json['isp']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      agent: json['agent']?.toString() ?? '',
      userId: json['UserId']?.toString() ?? '',
      site: (json['wlName']?.toString() ?? '').toUpperCase(),
    );
  }

  ActivityLogsData copyWith({int? id, String? loginTime, String? loginStatus, String? ip, String? isp, String? address, String? agent, String? userId, String? site}) {
    return ActivityLogsData(
      id: id ?? this.id,
      loginTime: loginTime ?? this.loginTime,
      loginStatus: loginStatus ?? this.loginStatus,
      ip: ip ?? this.ip,
      isp: isp ?? this.isp,
      address: address ?? this.address,
      agent: agent ?? this.agent,
      userId: userId ?? this.userId,
      site: site ?? this.site,
    );
  }

  static ActivityLogsData empty() {
    return ActivityLogsData(id: 0, loginTime: '', loginStatus: '', ip: '', isp: '', address: '', agent: '', userId: '', site: '');
  }

  bool get hasValidIp {
    final cleaned = ip.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidIsp {
    final cleaned = isp.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidAddress {
    final cleaned = address.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidAgent {
    final cleaned = agent.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }
}

List<TableColumn<ActivityLogsData>> activityLogColumns = [
  TableColumn(
    label: 'Login Date & Time',
    flex: 1,
    value: (row) => formattedDate(row.loginTime),
  ),
  TableColumn(
    label: 'Login Status',
    flex: 1,
    value: (row) => row.loginStatus,
    color: (row) => row.loginStatus.toLowerCase() == "login success" ? Colors.green : Colors.red,
  ),
  TableColumn(
    label: 'IP Address',
    flex: 1,
    alignRight: true,
    value: (row) => row.ip,
  ),
  TableColumn(
    label: 'ISP',
    flex: 2,
    alignRight: true,
    value: (row) => row.isp,
  ),
  TableColumn(
    label: 'City/State/Country',
    flex: 1,
    alignRight: true,
    value: (row) => row.address,
  ),
  TableColumn(
    label: 'User Agent Type',
    flex: 1,
    alignRight: true,
    value: (row) => row.agent,
  ),
];

List<TableColumn<ActivityLogsData>> orderLogColumns = [
  TableColumn(
    label: 'Date & Time',
    flex: 1,
    value: (row) => formattedDate(row.loginTime),
  ),
  TableColumn(
    label: 'Site',
    flex: 1,
    value: (row) => row.site,
  ),
  TableColumn(
    label: 'Order Status',
    flex: 1,
    value: (row) => row.loginStatus.isNotEmpty ? row.loginStatus : 'Order Placed',
  ),
  TableColumn(
    label: 'IP Address',
    flex: 1,
    value: (row) => row.ip,
  ),
  TableColumn(
    label: 'ISP',
    flex: 2,
    value: (row) => row.isp,
  ),
];

/// Account statement log model and response
class AccountStatementResponse {
  final List<AccountStatementLogModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  AccountStatementResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory AccountStatementResponse.fromJson(Map<dynamic, dynamic> json) {
    return AccountStatementResponse(
      data: (json['data'] as List? ?? []).map((e) => AccountStatementLogModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class AccountStatementLogModel {
  final String date;
  final double amount;
  final String type;
  final double balanceWithExposure;
  final String remark;
  final String fromTo;
  final String updater;

  AccountStatementLogModel({
    required this.date,
    required this.amount,
    required this.type,
    required this.balanceWithExposure,
    required this.remark,
    required this.fromTo,
    required this.updater,
  });

  factory AccountStatementLogModel.fromJson(Map<String, dynamic> json) {
    return AccountStatementLogModel(
      date: json['Date'] ?? '',
      amount: json['Amount'] ?? 0,
      type: json['Type'] ?? '',
      balanceWithExposure: json['BalanceWithExposure'] ?? 0,
      remark: json['Remark'] ?? '',
      fromTo: json['FromTo'] ?? '',
      updater: json['Updater'] ?? '',
    );
  }

  // Helper getters for display
  String get deposit => type.contains('Deposit') ? amount.toString() : '-';
  String get withdraw => type.contains('Withdraw') ? amount.toString() : '-';
}

List<TableColumn<AccountStatementLogModel>> accountStatementColumns = [
  TableColumn(
    label: 'Date/Time',
    flex: 2,
    value: (row) => formattedDate(row.date),
  ),
  TableColumn(
    label: 'Deposit',
    flex: 1,
    alignRight: true,
    value: (row) {
      if (row.type.contains('Deposit') || row.type.contains('Deposite')) {
        return formattedAmounts(row.amount);
      }
      return '-';
    },
  ),
  TableColumn(
    label: 'Withdraw',
    flex: 1,
    alignRight: true,
    value: (row) {
      if (row.type.contains('Withdraw')) {
        return formattedAmounts(row.amount);
      }
      return '-';
    },
  ),
  TableColumn(
    label: 'Balance (Include Exposure)',
    flex: 1.5,
    alignRight: true,
    value: (row) => formattedAmounts(row.balanceWithExposure),
  ),
  TableColumn(
    alignRight: true,
    label: 'Type',
    flex: 2,
    value: (row) => row.type.toUpperCase(),
  ),
  TableColumn(
    alignRight: true,
    label: 'Remark',
    flex: 2,
    value: (row) => row.remark,
  ),
  TableColumn(
    alignRight: true,
    label: 'From/To',
    flex: 1.5,
    value: (row) => row.fromTo,
  ),
  TableColumn(
    alignRight: true,
    label: 'Updater',
    flex: 1,
    value: (row) => row.updater,
  ),
];

///credit limit log model and response
class CreditLimitResponse {
  final List<CreditLimitLogModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  CreditLimitResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory CreditLimitResponse.fromJson(Map<dynamic, dynamic> json) {
    return CreditLimitResponse(
      data: (json['data'] as List? ?? []).map((e) => CreditLimitLogModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class CreditLimitLogModel {
  final String date;
  final double beforeInitialCredit;
  final double afterInitialCredit;
  final String remark;
  final String fromTo;

  CreditLimitLogModel({
    required this.date,
    required this.beforeInitialCredit,
    required this.afterInitialCredit,
    required this.remark,
    required this.fromTo,
  });

  factory CreditLimitLogModel.fromJson(Map<String, dynamic> json) {
    return CreditLimitLogModel(
      date: json['date'] ?? '',
      beforeInitialCredit: json['beforeBalance'] ?? 0,
      afterInitialCredit: json['afterBalance'] ?? 0,
      remark: json['comment'] ?? '',
      fromTo: json['fromTo'] ?? '',
    );
  }
}

List<TableColumn<CreditLimitLogModel>> creditLimitColumns = [
  TableColumn(
    label: 'Date/Time',
    flex: 2,
    value: (row) => formattedDate(row.date),
  ),
  TableColumn(
    label: 'Before Initial Credit Limit',
    flex: 1,
    alignRight: true,
    value: (row) => formattedAmounts(row.beforeInitialCredit),
  ),
  TableColumn(
    label: 'After Initial Credit Limit',
    flex: 1,
    alignRight: true,
    value: (row) => formattedAmounts(row.afterInitialCredit),
  ),
  TableColumn(
    label: 'Remark',
    flex: 2,
    value: (row) => row.remark,
  ),
  TableColumn(
    label: 'From/To',
    flex: 1.5,
    value: (row) => row.fromTo,
  ),
];

///transferred log model and response
class TransferredResponse {
  final List<TransferredLogModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  TransferredResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory TransferredResponse.fromJson(Map<dynamic, dynamic> json) {
    return TransferredResponse(
      data: (json['data'] as List? ?? []).map((e) => TransferredLogModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class TransferredLogModel {
  final String date;
  final double beforeSettlement;
  final double afterSettlement;
  final double settlement;
  final String remark;
  final String fromTo;

  TransferredLogModel({
    required this.date,
    required this.beforeSettlement,
    required this.afterSettlement,
    required this.settlement,
    required this.remark,
    required this.fromTo,
  });

  factory TransferredLogModel.fromJson(Map<String, dynamic> json) {
    return TransferredLogModel(
      date: json['date'] ?? '',
      beforeSettlement: json['beforeBalance'] ?? 0,
      afterSettlement: json['afterBalance'] ?? 0,
      settlement: json['amount'] ?? 0,
      remark: json['comment'] ?? '',
      fromTo: json['fromTo'] ?? '',
    );
  }
}

List<TableColumn<TransferredLogModel>> transferredColumns = [
  TableColumn(
    label: 'Date/Time',
    flex: 2,
    value: (row) => formattedDate(row.date),
  ),
  TableColumn(
    label: 'Before Settlement',
    flex: 1,
    alignRight: true,
    value: (row) => formattedAmounts(row.beforeSettlement),
  ),
  TableColumn(
    label: 'Settlement Amount',
    flex: 1,
    alignRight: true,
    value: (row) => formattedAmounts(row.settlement),
  ),
  TableColumn(
    label: 'After Settlement',
    flex: 1,
    alignRight: true,
    value: (row) => formattedAmounts(row.afterSettlement),
  ),
  TableColumn(
    label: 'Remarks',
    flex: 2,
    value: (row) => row.remark,
  ),
  TableColumn(
    label: 'From/To',
    flex: 1.5,
    value: (row) => row.fromTo,
  ),
];

///action log model and response
class ActionLogResponse {
  final List<ActionLogModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  ActionLogResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory ActionLogResponse.fromJson(Map<dynamic, dynamic> json) {
    return ActionLogResponse(
      data: (json['data'] as List? ?? []).map((e) => ActionLogModel.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class ActionLogModel {
  final String date;
  final String userId;
  final String site;
  final double depositWithdraw;
  final double originalBalance;
  final double accountBalance;
  final double beforeProfitLoss;
  final String tsCode;

  ActionLogModel({
    required this.date,
    required this.userId,
    required this.site,
    required this.depositWithdraw,
    required this.originalBalance,
    required this.accountBalance,
    required this.beforeProfitLoss,
    required this.tsCode,
  });

  factory ActionLogModel.fromJson(Map<String, dynamic> json) {
    return ActionLogModel(
      date: json['date'] ?? '',
      userId: json['userId'] ?? '',
      site: json['site'] ?? '',
      depositWithdraw: (json['depositWithdraw'] ?? 0).toDouble(),
      originalBalance: (json['originalBalance'] ?? 0).toDouble(),
      accountBalance: (json['accountBalance'] ?? 0).toDouble(),
      beforeProfitLoss: (json['beforeProfitLoss'] ?? 0).toDouble(),
      tsCode: json['tsCode'] ?? '',
    );
  }
}

List<NormalTableColumn<ActionLogModel>> actionLogColumns = [
  NormalTableColumn(
    alignCenter: true,
    label: 'Date',
    flex: 140,
    value: (row) => formattedDate(row.date),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'User ID',
    flex: 120,
    value: (row) => toNonEmptyString(row.userId),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'Site',
    flex: 120,
    value: (row) => toNonEmptyString(row.site),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'Deposit(+)/Withdraw(-)',
    flex: 200,
    value: (row) => formattedAmounts(row.depositWithdraw),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'Original Balance',
    flex: 120,
    value: (row) => formattedAmounts(row.originalBalance),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'Account Balance',
    flex: 120,
    value: (row) => formattedAmounts(row.accountBalance),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'Before ProfitLoss',
    flex: 120,
    value: (row) => formattedAmounts(row.beforeProfitLoss),
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'TS Code',
    flex: 150,
    value: (row) => toNonEmptyString(row.tsCode),
  ),
];
