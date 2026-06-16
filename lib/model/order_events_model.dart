class OrderEventResponse {
  final int status;
  final List<OrderEventData> data;
  final String message;

  OrderEventResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory OrderEventResponse.fromJson(Map<dynamic, dynamic> json) {
    return OrderEventResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List? ?? []).map((e) => OrderEventData.fromJson(e as Map<String, dynamic>)).toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

class OrderEventData {
  final String eventName;
  final String eventId; // Changed to String to handle both formats
  final String sportName;
  final List<OrderMarketData> markets;

  OrderEventData({
    required this.eventName,
    required this.eventId,
    required this.sportName,
    required this.markets,
  });

  factory OrderEventData.fromJson(Map<String, dynamic> json) {
    return OrderEventData(
      eventName: json['eventName']?.toString() ?? '',
      eventId: _parseEventId(json['eventId']), // Handle int or string
      sportName: json['sportName']?.toString() ?? '',
      markets: (json['markets'] as List? ?? []).map((e) => OrderMarketData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Helper method to parse eventId whether it's int or string
  static String _parseEventId(dynamic eventId) {
    if (eventId == null) return '';
    if (eventId is int) return eventId.toString();
    if (eventId is String) return eventId;
    return '';
  }
}

class OrderMarketData {
  final String marketName;
  final String marketId;

  OrderMarketData({
    required this.marketName,
    required this.marketId,
  });

  factory OrderMarketData.fromJson(Map<String, dynamic> json) {
    return OrderMarketData(
      marketName: json['marketName']?.toString() ?? '',
      marketId: _parseMarketId(json['marketId']), // Handle marketId properly
    );
  }

  // Helper method to parse marketId (could be string or int)
  static String _parseMarketId(dynamic marketId) {
    if (marketId == null) return '';
    if (marketId is int) return marketId.toString();
    if (marketId is String) return marketId;
    return '';
  }
}
