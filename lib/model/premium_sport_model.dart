class PremiumSportResponse {
  final int status;
  final String message;
  final List<PremiumSportData> data;

  PremiumSportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PremiumSportResponse.fromJson(Map<dynamic, dynamic> json) {
    return PremiumSportResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? "",
      data: (json['data'] as List?)?.map((e) => PremiumSportData.fromJson(e)).toList() ?? [],
    );
  }
}

class PremiumSportData {
  final String sport;
  final List<PremiumDateDetail> dateDetail;

  PremiumSportData({
    required this.sport,
    required this.dateDetail,
  });

  factory PremiumSportData.fromJson(Map<String, dynamic> json) {
    return PremiumSportData(
      sport: json['sport'] ?? "",
      dateDetail: (json['dateDetail'] as List?)?.map((e) => PremiumDateDetail.fromJson(e)).toList() ?? [],
    );
  }
}

class PremiumDateDetail {
  final String date;
  final List<PremiumDetail> details;

  PremiumDateDetail({
    required this.date,
    required this.details,
  });

  factory PremiumDateDetail.fromJson(Map<String, dynamic> json) {
    return PremiumDateDetail(
      date: json['date'] ?? "",
      details: (json['details'] as List?)?.map((e) => PremiumDetail.fromJson(e)).toList() ?? [],
    );
  }
}

class PremiumDetail {
  final String eventName;
  final String marketName;
  final String marketId;
  final String runnerName;
  final String runnerId;
  final double matchedAmount;
  final double avgOdd;

  PremiumDetail({
    required this.eventName,
    required this.marketName,
    required this.marketId,
    required this.runnerName,
    required this.runnerId,
    required this.matchedAmount,
    required this.avgOdd,
  });

  factory PremiumDetail.fromJson(Map<String, dynamic> json) {
    return PremiumDetail(
      eventName: json['eventName'] ?? "",
      marketName: json['marketName'] ?? "",
      marketId: json['marketId'] ?? "",
      runnerName: json['runnerName'] ?? "",
      runnerId: json['runnerId'] ?? "",
      matchedAmount: (json['matchedAmount'] ?? 0).toDouble(),
      avgOdd: (json['avgOdd'] ?? 0).toDouble(),
    );
  }
}
