import '../bloc/signalRBloc/protoUsage/receive/receive.pb.dart';

class OpenFancyResponse {
  final int status;
  final List<OpenFancyData> data;
  final String message;

  OpenFancyResponse({required this.status, required this.data, required this.message});

  factory OpenFancyResponse.fromJson(Map<dynamic, dynamic> json) {
    return OpenFancyResponse(status: json['status'] ?? 0, data: (json['data'] as List? ?? []).map((e) => OpenFancyData.fromJson(e)).toList(), message: json['message'] ?? '');
  }
}

class OpenFancyData {
  final String sid;
  final String sportName;
  final List<FancyDate> dates;

  OpenFancyData({
    required this.sid,
    required this.sportName,
    required this.dates,
  });

  factory OpenFancyData.fromJson(Map<String, dynamic> json) {
    return OpenFancyData(
      sid: json['sid'] ?? '',
      sportName: json['sportName'] ?? '',
      dates: (json['dates'] as List? ?? []).map((item) => FancyDate.fromJson(item)).toList(),
    );
  }
}

class FancyDate {
  final String date;
  final List<FancyEvent> events;

  FancyDate({
    required this.date,
    required this.events,
  });

  factory FancyDate.fromJson(Map<String, dynamic> json) {
    return FancyDate(
      date: (json['date'] ?? ''),
      events: (json['events'] as List? ?? []).map((item) => FancyEvent.fromJson(item)).toList(),
    );
  }
}

class FancyEvent {
  final String eventId;
  final String eventName;
  final FancyRisk risk;

  FancyEvent({
    required this.eventId,
    required this.eventName,
    required this.risk,
  });

  factory FancyEvent.fromJson(Map<String, dynamic> json) {
    return FancyEvent(
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      risk: FancyRisk.fromJson(json['risk'] ?? {}),
    );
  }
}

class FancyRisk {
  final String marketId;
  final String? marketName;
  final String marketTime;
  final double totalStack;
  final bool sportingEvent;
  final String status;
  final String marketType;

  final List<FancyRunner> runners;
  final LinePnl linePnl;
  final MarketCondition? marketCondition;

  FancyRisk({
    required this.sportingEvent,
    required this.status,
    required this.marketId,
    this.marketName,
    required this.marketTime,
    required this.totalStack,
    required this.runners,
    required this.linePnl,
    required this.marketType,
    this.marketCondition,
  });

  factory FancyRisk.fromJson(Map<String, dynamic> json) {
    return FancyRisk(
      sportingEvent: json['sportingEvent'] ?? false,
      status: json['status'] ?? '',
      marketType: json['marketType'] ?? '',
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'],
      marketTime: json['marketTime'] ?? '',
      totalStack: (json['totalStack'] ?? 0).toDouble(),
      runners: (json['runners'] as List? ?? []).map((runner) => FancyRunner.fromJson(runner)).toList(),
      linePnl: LinePnl.fromJson(json['linePnl'] ?? {}),
      marketCondition: MarketCondition.fromJson(json['marketCondition'] ?? {}),
    );
  }

  factory FancyRisk.fromBuffer(ABCModel fancyRisk) {
    return FancyRisk(
      sportingEvent: fancyRisk.sportingEvent,
      marketType: fancyRisk.marketType,
      status: fancyRisk.status.toString(),
      marketId: fancyRisk.marketId,
      marketName: fancyRisk.marketName.isNotEmpty ? fancyRisk.marketName : null,
      marketTime: fancyRisk.marketTime,
      totalStack: 0,
      runners: fancyRisk.runner
          .map(
            (runner) => FancyRunner(
              runnerId: runner.runnerId,
              runnerName: runner.name,
              backs: runner.backs,
              lays: runner.lays,
            ),
          )
          .toList(),
      linePnl: LinePnl(
        max: 0,
        min: 0,
      ),
      marketCondition: MarketCondition(
        marketId: fancyRisk.marketId,
        minBet: fancyRisk.marketCondition.minBet.toDouble(),
        maxBet: fancyRisk.marketCondition.maxBet.toDouble(),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FancyRisk && runtimeType == other.runtimeType && marketId == other.marketId && marketName == other.marketName;

  @override
  int get hashCode => marketId.hashCode;
}

class MarketCondition {
  final String marketId;
  final double minBet;
  final double maxBet;
  MarketCondition({
    required this.marketId,
    required this.minBet,
    required this.maxBet,
  });

  factory MarketCondition.fromJson(Map<String, dynamic> json) {
    return MarketCondition(
      marketId: json['marketId'] ?? '',
      minBet: json['minBet'] ?? 0,
      maxBet: json['maxBet'] ?? 0,
    );
  }
  @override
  bool operator ==(Object other) => identical(this, other) || other is FancyRisk && runtimeType == other.runtimeType && marketId == other.marketId;

  @override
  int get hashCode => marketId.hashCode;
}

class FancyRunner {
  final String runnerId;
  final String runnerName;
  List<dynamic> backs;
  List<dynamic> lays;

  FancyRunner({
    required this.runnerId,
    required this.runnerName,
    required this.backs,
    required this.lays,
  });

  factory FancyRunner.fromJson(Map<String, dynamic> json) {
    return FancyRunner(
      runnerId: json['runnerId'] ?? '',
      runnerName: json['runnerName'] ?? '',
      backs: [],
      lays: [],
    );
  }
  @override
  bool operator ==(Object other) => identical(this, other) || other is FancyRisk && runtimeType == other.runtimeType && runnerId == other.marketId;

  @override
  int get hashCode => runnerId.hashCode;
}

class LinePnl {
  final double max;
  final double min;

  LinePnl({required this.max, required this.min});

  factory LinePnl.fromJson(Map<String, dynamic> json) {
    return LinePnl(
      max: (json['max'] ?? 0).toDouble(),
      min: (json['min'] ?? 0).toDouble(),
    );
  }
}
