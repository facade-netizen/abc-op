import 'sport_wise_report_model.dart';

class OpenOddsResponse {
  final int status;
  final List<OpenOddsData> data;
  final String message;

  OpenOddsResponse({required this.status, required this.data, required this.message});

  factory OpenOddsResponse.fromJson(Map<dynamic, dynamic> json) {
    return OpenOddsResponse(status: json['status'] ?? 0, data: (json['data'] as List? ?? []).map((e) => OpenOddsData.fromJson(e)).toList(), message: json['message'] ?? '');
  }
}

class OpenOddsData {
  final String sid;
  final String sportName;
  final List<OddsDate> dates;

  OpenOddsData({
    required this.sid,
    required this.sportName,
    required this.dates,
  });

  factory OpenOddsData.fromJson(Map<String, dynamic> json) {
    return OpenOddsData(
      sid: json['sid'] ?? '',
      sportName: json['sportName'] ?? '',
      dates: (json['dates'] as List? ?? []).map((item) => OddsDate.fromJson(item)).toList(),
    );
  }
}

class OddsDate {
  final String date;
  final List<OddsEvent> events;

  OddsDate({
    required this.date,
    required this.events,
  });

  factory OddsDate.fromJson(Map<String, dynamic> json) {
    return OddsDate(
      date: json['date'] ?? '',
      events: (json['events'] as List? ?? []).map((item) => OddsEvent.fromJson(item)).toList(),
    );
  }
}

class OddsEvent {
  final String eventId;
  final String eventName;
  final OddsRisk risk;

  OddsEvent({
    required this.eventId,
    required this.eventName,
    required this.risk,
  });

  factory OddsEvent.fromJson(Map<String, dynamic> json) {
    return OddsEvent(
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      risk: OddsRisk.fromJson(json['risk'] ?? {}),
    );
  }
}

class OddsRisk {
  final String marketId;
  final MarketType marketType;
  final String marketTypeString;
  final String? marketName;
  final String marketTime;
  final double totalStack;
  final List<OddsRunner> runners;

  OddsRisk({
    required this.marketId,
    required this.marketType,
    required this.marketTypeString,
    this.marketName,
    required this.marketTime,
    required this.totalStack,
    required this.runners,
  });

  factory OddsRisk.fromJson(Map<String, dynamic> json) {
    final marketTypeValue = json['marketType']?.toString() ?? "";
    return OddsRisk(
      marketId: json['marketId'] ?? '',
      marketType: getReportTypeString(marketTypeValue),
      marketTypeString: marketTypeValue,
      marketName: json['marketName'],
      marketTime: json['marketTime'] ?? '',
      totalStack: (json['totalStack'] ?? 0).toDouble(),
      runners: (json['runners'] as List? ?? []).map((item) => OddsRunner.fromJson(item)).toList(),
    );
  }
}

class OddsRunner {
  final String runnerId;
  final String runnerName;
  final num pnl;

  OddsRunner({required this.runnerId, required this.runnerName, required this.pnl});

  factory OddsRunner.fromJson(Map<String, dynamic> json) {
    return OddsRunner(runnerId: json['runnerId'] ?? '', runnerName: json['runnerName'] ?? '', pnl: json['pnl'] ?? 0);
  }
}
