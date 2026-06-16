class CasinoHistoryResponse {
  final double status;
  final List<CasinoHistoryData> data;
  final String message;

  CasinoHistoryResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory CasinoHistoryResponse.fromJson(Map<dynamic, dynamic>? json) {
    return CasinoHistoryResponse(
      status: json?['status'] ?? 0,
      data: (json?['data'] as List<dynamic>?)?.map((e) => CasinoHistoryData.fromJson(e)).toList() ?? [],
      message: json?['message'] ?? '',
    );
  }
}

class CasinoHistoryData {
  final String betType;
  final double pnl;
  final String? time;
  final List<GameReport> report;

  CasinoHistoryData({
    required this.betType,
    required this.pnl,
    required this.time,
    required this.report,
  });

  factory CasinoHistoryData.fromJson(Map<String, dynamic>? json) {
    return CasinoHistoryData(
      betType: json?['betType'] ?? '',
      pnl: json?['pnl'] ?? 0,
      time: json?['time'] ?? '',
      report: (json?['report'] as List<dynamic>?)?.map((e) => GameReport.fromJson(e)).toList() ?? [],
    );
  }
}

class GameReport {
  final String gameId;
  final String name;
  final double turnover;
  final double pnl;
  final List<BetDetail> detail;

  GameReport({
    required this.gameId,
    required this.name,
    required this.turnover,
    required this.pnl,
    required this.detail,
  });

  factory GameReport.fromJson(Map<String, dynamic>? json) {
    return GameReport(
      gameId: json?['gameId'] ?? '',
      name: json?['name'] ?? '',
      turnover: json?['turnover'] ?? 0,
      pnl: json?['pnl'] ?? 0,
      detail: (json?['detail'] as List<dynamic>?)?.map((e) => BetDetail.fromJson(e)).toList() ?? [],
    );
  }
}

class BetDetail {
  final double index;
  final String roundId;
  final DateTime? betTime;
  final double betType;
  final double bet;
  final double win;
  final double pnl;
  final String round;
  final String transactionId;

  BetDetail({
    required this.index,
    required this.roundId,
    required this.betTime,
    required this.betType,
    required this.bet,
    required this.win,
    required this.pnl,
    required this.round,
    required this.transactionId,
  });

  factory BetDetail.fromJson(Map<String, dynamic>? json) {
    return BetDetail(
      index: json?['index'] ?? 0,
      roundId: json?['roundId'] ?? '',
      betTime: json?['betTime'] != null ? DateTime.tryParse(json!['betTime']) : null,
      betType: json?['betType'] ?? 0,
      bet: json?['bet'] ?? 0,
      win: json?['win'] ?? 0,
      pnl: json?['pnl'] ?? 0,
      round: json?['round'] ?? '',
      transactionId: json?['transactionId'] ?? '',
    );
  }
}
