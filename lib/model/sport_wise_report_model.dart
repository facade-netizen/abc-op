class SportWiseReportResponse {
  final int status;
  final String message;
  final List<SportWiseReportData> data;

  SportWiseReportResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory SportWiseReportResponse.fromJson(Map<dynamic, dynamic> json) {
    return SportWiseReportResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List?)?.map((e) => SportWiseReportData.fromJson(e)).toList() ?? [],
      message: json['message'] ?? "",
    );
  }
}

class SportWiseReportData {
  final String date;
  final List<Detail> detail;

  SportWiseReportData({
    required this.date,
    required this.detail,
  });

  factory SportWiseReportData.fromJson(Map<String, dynamic> json) {
    return SportWiseReportData(
      date: json['date'] ?? "",
      detail: (json['detail'] as List?)?.map((e) => Detail.fromJson(e)).toList() ?? [],
    );
  }
}

class Detail {
  final String eventName;
  final MarketType marketType;
  final String marketTypeString;
  final String runnerName;
  final String runnerId;
  final String marketId;
  final double avgBackOdds;
  final double backStake;
  final double avgLayOdds;
  final double layStake;

  Detail({
    required this.eventName,
    required this.marketType,
    required this.marketTypeString,
    required this.runnerName,
    required this.runnerId,
    required this.marketId,
    required this.avgBackOdds,
    required this.backStake,
    required this.avgLayOdds,
    required this.layStake,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    final marketTypeValue = json['marketType']?.toString() ?? "";
    return Detail(
      eventName: json['evevtName'] ?? "",
      marketType: getReportTypeString(marketTypeValue),
      marketTypeString: marketTypeValue,
      runnerName: json['runnerName'] ?? "",
      runnerId: json['runnerId']?.toString() ?? "",
      marketId: json['marketId']?.toString() ?? "",
      avgBackOdds: (json['avgBackOdds'] ?? 0).toDouble(),
      backStake: (json['backStake'] ?? 0).toDouble(),
      avgLayOdds: (json['avgLayOdds'] ?? 0).toDouble(),
      layStake: (json['layStake'] ?? 0).toDouble(),
    );
  }
}

String sportName(String sid) {
  switch (sid) {
    case '1':
      return "Soccer";
    case '2':
      return "Tennis";
    case '3':
      return "Basketball";
    case '4':
      return "Cricket";
    case '7':
      return "Horse Racing";
    case '4339':
      return "Greyhound Racing";
    case '2378961':
      return "Politics";
    default:
      return "";
  }
}

enum MarketType { matchOdds, bookmaker, otherMarkets }

MarketType getReportTypeString(String type) {
  switch (type.toLowerCase()) {
    case 'match_odds':
      return MarketType.matchOdds;
    case 'bookmaker':
      return MarketType.bookmaker;
    default:
      return MarketType.otherMarkets;
  }
}

String getReportType(MarketType type, {String? originalType}) {
  switch (type) {
    case MarketType.matchOdds:
      return '_Match Odds';
    case MarketType.bookmaker:
      return '_Bookmaker';
    case MarketType.otherMarkets:
      return originalType ?? '_Other Markets';
  }
}
