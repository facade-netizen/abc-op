class OpenBMResponse {
  final int status;
  final List<OpenBMData> data;
  final String message;

  OpenBMResponse({required this.status, required this.data, required this.message});

  factory OpenBMResponse.fromJson(Map<dynamic, dynamic> json) {
    return OpenBMResponse(
        status: json['status'] ?? 0, data: (json['data'] as List? ?? []).map((e) => OpenBMData.fromJson(e as Map<String, dynamic>)).toList(), message: json['message'] ?? '');
  }
}

class OpenBMData {
  final String sid;
  final String sportName;
  final List<BMDate> dates;

  OpenBMData({
    required this.sid,
    required this.sportName,
    required this.dates,
  });

  factory OpenBMData.fromJson(Map<String, dynamic> json) {
    return OpenBMData(
      sid: json['sid'] ?? '',
      sportName: json['sportName'] ?? '',
      dates: (json['dates'] as List? ?? []).map((item) => BMDate.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class BMDate {
  final String date;
  final List<BMEvent> events;

  BMDate({
    required this.date,
    required this.events,
  });

  factory BMDate.fromJson(Map<String, dynamic> json) {
    return BMDate(
      date: json['date'] ?? '',
      events: (json['events'] as List? ?? []).map((item) => BMEvent.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class BMEvent {
  final String eventId;
  final String eventName;
  final BMRisk risk;

  BMEvent({
    required this.eventId,
    required this.eventName,
    required this.risk,
  });

  factory BMEvent.fromJson(Map<String, dynamic> json) {
    return BMEvent(
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      risk: BMRisk.fromJson(json['risk'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class BMRisk {
  final String marketId;
  final String? marketName;
  final String marketTime;
  final double totalStack;
  final List<BMRunner> runners;

  BMRisk({
    required this.marketId,
    this.marketName,
    required this.marketTime,
    required this.totalStack,
    required this.runners,
  });

  factory BMRisk.fromJson(Map<String, dynamic> json) {
    return BMRisk(
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'],
      marketTime: json['marketTime'] ?? '',
      totalStack: (json['totalStack'] ?? 0).toDouble(),
      runners: (json['runners'] as List? ?? []).map((item) => BMRunner.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class BMRunner {
  final String runnerId;
  final String runnerName;
  final num pnl;

  BMRunner({required this.runnerId, required this.runnerName, required this.pnl});

  factory BMRunner.fromJson(Map<String, dynamic> json) {
    return BMRunner(runnerId: json['runnerId'] ?? '', runnerName: json['runnerName'] ?? '', pnl: json['pnl'] ?? 0);
  }
}
