class RacingEventData {
  final String type;
  final String country;
  final String events;
  final double matchedAmount;
  final String? eventId; // Optional field
  final String? eventName; // Optional field

  RacingEventData({
    required this.type,
    required this.country,
    required this.events,
    required this.matchedAmount,
    this.eventId,
    this.eventName,
  });

  factory RacingEventData.fromJson(Map<String, dynamic> json) {
    return RacingEventData(
      type: json['type'] ?? '',
      country: json['country'] ?? '',
      events: json['events'] ?? '',
      matchedAmount: (json['matchedAmount'] ?? 0).toDouble(),
      eventId: json['eventId'],
      eventName: json['eventName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'country': country,
      'events': events,
      'matchedAmount': matchedAmount,
      'eventId': eventId,
      'eventName': eventName,
    };
  }
}
