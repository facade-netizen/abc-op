class FancyBookResponse {
  final int status;
  final List<RunData> data;
  final String message;

  FancyBookResponse({required this.status, required this.data, required this.message});

  factory FancyBookResponse.fromJson(Map<dynamic, dynamic> json) {
    return FancyBookResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)?.map((item) => RunData.fromJson(item)).toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class RunData {
  final int runs;
  final double amount;

  RunData({required this.runs, required this.amount});

  factory RunData.fromJson(Map<String, dynamic> json) {
    return RunData(runs: json['runs'] ?? 0, amount: (json['amount'] ?? 0).toDouble());
  }
}
