class BalanceLogSummaryResponse {
  final List<BalanceLogSummaryItem> data;
  final int page;
  final int pageSize;

  final String status;
  final int totalPages;
  final int totalRecords;

  BalanceLogSummaryResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory BalanceLogSummaryResponse.fromJson(Map<dynamic, dynamic> json) {
    return BalanceLogSummaryResponse(
      data: (json['data'] as List).map((e) => BalanceLogSummaryItem.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class BalanceLogSummaryItem {
  final int id;
  final String accountId;
  final String userId;
  final String userName;
  final String site;
  final String eventId;
  final String eventName;
  final String marketId;
  final String marketName;
  final String categoryType;
  final double beforeBalance;
  final double afterBalance;
  final double profitLoss;
  final String remark;
  final String createDate;

  BalanceLogSummaryItem({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.userName,
    required this.site,
    required this.eventId,
    required this.eventName,
    required this.marketId,
    required this.marketName,
    required this.categoryType,
    required this.beforeBalance,
    required this.afterBalance,
    required this.profitLoss,
    required this.remark,
    required this.createDate,
  });

  factory BalanceLogSummaryItem.fromJson(Map<String, dynamic> json) {
    return BalanceLogSummaryItem(
      id: json['id'] ?? 0,
      accountId: json['accountId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      site: (json['site'] ?? '').toString().toUpperCase(),
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? '',
      categoryType: json['categoryType'] ?? '',
      beforeBalance: (json['beforeBalance'] as num?)?.toDouble() ?? 0.0,
      afterBalance: (json['afterBalance'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      remark: (json['remark'] ?? '').toUpperCase(),
      createDate: json['createDate'] ?? '',
    );
  }
}
