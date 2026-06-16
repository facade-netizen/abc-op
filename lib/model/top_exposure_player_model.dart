import 'bm_book_model.dart';

class TopPlayerExposureResponse {
  final int status;
  final TopPlayerExposureDataWrapper data;
  final String message;

  TopPlayerExposureResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory TopPlayerExposureResponse.fromJson(Map<dynamic, dynamic> json) {
    return TopPlayerExposureResponse(
      status: json['status'] ?? 0,
      data: TopPlayerExposureDataWrapper.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class TopPlayerExposureDataWrapper {
  final List<TopPlayerExposureData> topExposure;
  final List<TopPlayerExposureData> topBalance;

  TopPlayerExposureDataWrapper({
    required this.topExposure,
    required this.topBalance,
  });

  factory TopPlayerExposureDataWrapper.fromJson(Map<String, dynamic> json) {
    return TopPlayerExposureDataWrapper(
      topExposure: (json['topExposure'] as List<dynamic>?)?.map((e) => TopPlayerExposureData.fromJson(e)).toList() ?? [],
      topBalance: (json['topBalance'] as List<dynamic>?)?.map((e) => TopPlayerExposureData.fromJson(e)).toList() ?? [],
    );
  }
}

class TopPlayerExposureData {
  final String userId;
  final String userName;
  final double balance;
  final double exposure;
  final double amount;
  final List<UplineData> upline;

  TopPlayerExposureData({
    required this.userId,
    required this.userName,
    required this.balance,
    required this.exposure,
    required this.amount,
    required this.upline,
  });

  factory TopPlayerExposureData.fromJson(Map<String, dynamic> json) {
    return TopPlayerExposureData(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      exposure: (json['exposure'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      upline: (json['upline'] as List<dynamic>?)?.map((e) => UplineData.fromJson(e)).toList() ?? [],
    );
  }
}
