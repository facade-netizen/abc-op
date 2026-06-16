import '../reusable/formatters.dart';
import '../reusable/normal_pagination_table.dart';

class UserLogResponse {
  final int status;
  final List<UserLogModel> data;
  final String message;

  UserLogResponse({required this.status, required this.data, required this.message});

  factory UserLogResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<UserLogModel> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => UserLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return UserLogResponse(status: json['status'] as int? ?? 0, data: parsedData, message: json['message']?.toString() ?? '');
  }
}

class UserLogModel {
  final int id;
  final String updater;
  final String userName;
  final String role;
  final String updaterRole;
  final String logAction;
  final String oldValue;
  final String newValue;
  final String status;
  final String createDate;
  final String updateDate;
  final String upLine;
  final String site;

  UserLogModel({
    required this.id,
    required this.updater,
    required this.userName,
    required this.role,
    required this.updaterRole,
    required this.logAction,
    required this.oldValue,
    required this.newValue,
    required this.status,
    required this.createDate,
    required this.updateDate,
    required this.site,
    required this.upLine,
  });

  factory UserLogModel.fromJson(Map<String, dynamic> map) {
    final createDate = map['CreateDate'] ?? "";
    final updateDate = map['UpdateDate'];
    final newValue = map['NewValue'] ?? "";
    final status = map['Status'];

    return UserLogModel(
      id: map['Id'] ?? 0,
      updater: map['Updater'] ?? "",
      upLine: map['UpLine'] ?? "",
      site: (map['Site'] ?? "").toString().toUpperCase(),
      userName: map['UserName'] ?? "",
      role: map['Role'] ?? "",
      updaterRole: map['UpdaterRole'] ?? "",
      logAction: map['LogAction'] ?? "",
      oldValue: map['OldValue'] ?? "",
      newValue: newValue,
      status: (status == null || status.toString().isEmpty) ? newValue : status,
      createDate: createDate,
      updateDate: (updateDate == null || updateDate.toString().isEmpty) ? createDate : updateDate,
    );
  }
}

List<NormalTableColumn<UserLogModel>> agencyHistoryColumns = [
  NormalTableColumn(label: 'User ID', flex: 120, value: (row) => toNonEmptyString(row.userName), alignCenter: true),
  NormalTableColumn(alignCenter: true, label: 'Site', flex: 100, value: (row) => toNonEmptyString(row.site)),
  NormalTableColumn(alignCenter: true, label: 'Level', flex: 80, value: (row) => toNonEmptyString(row.role)),
  NormalTableColumn(alignCenter: true, label: 'Upline', flex: 200, value: (row) => toNonEmptyString(row.upLine)),
  NormalTableColumn(alignCenter: true, label: 'Function Type', flex: 120, value: (row) => toNonEmptyString(row.logAction)),
  NormalTableColumn(
    alignCenter: true,
    label: 'Old Value',
    flex: 120,
    value: (row) {
      final value = toNonEmptyString(row.oldValue);
      final hasNumber = RegExp(r'\d').hasMatch(value);
      return hasNumber ? formattedAmounts(double.tryParse(value) ?? 0) : value;
    },
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'New Value',
    flex: 120,
    value: (row) {
      final value = toNonEmptyString(row.newValue);
      final hasNumber = RegExp(r'\d').hasMatch(value);
      return hasNumber ? formattedAmounts(double.tryParse(value) ?? 0) : value;
    },
  ),
  NormalTableColumn(alignCenter: true, label: 'Status', flex: 80, value: (row) => toNonEmptyString(row.status)),
  NormalTableColumn(alignCenter: true, label: 'Updater', flex: 120, value: (row) => toNonEmptyString(row.updater)),
  NormalTableColumn(alignCenter: true, label: 'Created Date', flex: 120, value: (row) => formattedDate(row.createDate)),
];
List<NormalTableColumn<UserLogModel>> opActionLogColumns = [
  NormalTableColumn(label: 'OP', flex: 120, value: (row) => toNonEmptyString(row.updater), alignCenter: true),
  NormalTableColumn(alignCenter: true, label: 'Function Type', flex: 120, value: (row) => toNonEmptyString(row.logAction)),
  NormalTableColumn(
    alignCenter: true,
    label: 'Old Value',
    flex: 120,
    value: (row) {
      final value = toNonEmptyString(row.oldValue);
      final hasNumber = RegExp(r'\d').hasMatch(value);
      return hasNumber ? formattedAmounts(double.tryParse(value) ?? 0) : value;
    },
  ),
  NormalTableColumn(
    alignCenter: true,
    label: 'New Value',
    flex: 120,
    value: (row) {
      final value = toNonEmptyString(row.newValue);
      final hasNumber = RegExp(r'\d').hasMatch(value);
      return hasNumber ? formattedAmounts(double.tryParse(value) ?? 0) : value;
    },
  ),
  NormalTableColumn(alignCenter: true, label: 'Updated Date', flex: 140, value: (row) => formattedDate(row.updateDate)),
];
