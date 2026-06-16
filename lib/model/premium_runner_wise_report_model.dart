import 'bm_book_model.dart';

class PremiumRunnerWiseReportResponse {
  final int status;
  final PremiumRunnerWiseReportData data;
  final String message;

  PremiumRunnerWiseReportResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory PremiumRunnerWiseReportResponse.fromJson(Map<dynamic, dynamic> json) {
    return PremiumRunnerWiseReportResponse(
      status: json['status'] ?? 0,
      data: PremiumRunnerWiseReportData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? "",
    );
  }
}

class PremiumRunnerWiseReportData {
  final String runnerName;
  final String eventName;
  final List<PremiumRunnerWiseReportDetail> detail;

  PremiumRunnerWiseReportData({
    required this.runnerName,
    required this.eventName,
    required this.detail,
  });

  factory PremiumRunnerWiseReportData.fromJson(Map<String, dynamic> json) {
    return PremiumRunnerWiseReportData(
      runnerName: json['runnerName'] ?? "",
      eventName: json['eventName'] ?? "",
      detail: (json['detail'] as List? ?? []).map((e) => PremiumRunnerWiseReportDetail.fromJson(e)).toList(),
    );
  }
}

class PremiumRunnerWiseReportDetail {
  final String uuid;
  final String date;
  final double avgBackOdds;
  final double backStake;
  final double profit;
  final List<UplineData> upline;

  PremiumRunnerWiseReportDetail({
    required this.uuid,
    required this.date,
    required this.avgBackOdds,
    required this.backStake,
    required this.profit,
    required this.upline,
  });

  factory PremiumRunnerWiseReportDetail.fromJson(Map<String, dynamic> json) {
    return PremiumRunnerWiseReportDetail(
      uuid: json['uuid'] ?? "",
      date: json['date'] ?? "",
      avgBackOdds: (json['avgBackOdds'] ?? 0).toDouble(),
      backStake: (json['backStake'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      upline: (json['upline'] as List? ?? []).map((item) => UplineData.fromJson(item)).toList(),
    );
  }
}
