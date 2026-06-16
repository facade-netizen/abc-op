import 'bm_book_model.dart';

class RunnerWiseReportResponse {
  final int status;
  final RunnerWiseReportData data;
  final String message;

  RunnerWiseReportResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory RunnerWiseReportResponse.fromJson(Map<dynamic, dynamic> json) {
    return RunnerWiseReportResponse(
      status: json['status'] ?? 0,
      data: RunnerWiseReportData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? "",
    );
  }
}

class RunnerWiseReportData {
  final String runnerName;
  final String eventName;
  final List<RunnerWiseReportDetail> detail;

  RunnerWiseReportData({
    required this.runnerName,
    required this.eventName,
    required this.detail,
  });

  factory RunnerWiseReportData.fromJson(Map<String, dynamic> json) {
    return RunnerWiseReportData(
      runnerName: json['runnerName'] ?? "",
      eventName: json['eventName'] ?? "",
      detail: (json['detail'] as List? ?? []).map((e) => RunnerWiseReportDetail.fromJson(e)).toList(),
    );
  }
}

class RunnerWiseReportDetail {
  final String uuid;
  final String date;
  final double avgBackOdds;
  final double backStake;
  final double profit;
  final double avgLayOdds;
  final double layStake;
  final double liability;
  final List<UplineData> upline;

  RunnerWiseReportDetail({
    required this.uuid,
    required this.date,
    required this.avgBackOdds,
    required this.backStake,
    required this.profit,
    required this.avgLayOdds,
    required this.layStake,
    required this.liability,
    required this.upline,
  });

  factory RunnerWiseReportDetail.fromJson(Map<String, dynamic> json) {
    return RunnerWiseReportDetail(
      uuid: json['uuid'] ?? "",
      date: json['date'] ?? "",
      avgBackOdds: (json['avgBackOdds'] ?? 0).toDouble(),
      backStake: (json['backStake'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      avgLayOdds: (json['avgLayOdds'] ?? 0).toDouble(),
      layStake: (json['layStake'] ?? 0).toDouble(),
      liability: (json['liability'] ?? 0).toDouble(),
      upline: (json['upline'] as List? ?? []).map((item) => UplineData.fromJson(item)).toList(),
    );
  }
}
