class LifeTimeReportResponse {
  final int status;
  final List<LifeTimeReport> data;
  final String message;

  LifeTimeReportResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory LifeTimeReportResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<LifeTimeReport> parsedData;

    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => LifeTimeReport.fromJson(e as Map<String, dynamic>)).toList();
      // Sort order: 0, 2, 1, 3, 4
      const typeOrder = {0: 0, 2: 1, 1: 2, 3: 3, 4: 4};
      parsedData.sort((a, b) {
        final aOrder = typeOrder[a.type] ?? 999;
        final bOrder = typeOrder[b.type] ?? 999;
        return aOrder.compareTo(bOrder);
      });
    } else {
      parsedData = [];
    }

    return LifeTimeReportResponse(
      status: json['status'] as int? ?? 0,
      data: parsedData,
      message: json['message']?.toString() ?? '',
    );
  }
}

class LifeTimeReport {
  final int type;
  final String bettingType;
  final List<LifeTimeReportDetail> detailData;

  LifeTimeReport({
    required this.type,
    required this.bettingType,
    required this.detailData,
  });

  factory LifeTimeReport.fromJson(Map<String, dynamic> json) => LifeTimeReport(
        type: json['type'] ?? 0,
        bettingType: bettingTypeName(json['type'] ?? 0),
        detailData: (json['detailData'] as List).map((e) => LifeTimeReportDetail.fromJson(e)).toList(),
      );
}

String bettingTypeName(int type) {
  switch (type) {
    case 0:
      return 'Exchange';
    case 1:
      return 'Fancy';
    case 2:
      return 'BookMaker';
    case 3:
      return 'Sportsbook';
    case 4:
      return 'Casino';
    default:
      return 'Sports';
  }
}

class LifeTimeReportDetail {
  final String name;
  final double layCount;
  final double backCount;
  final double totalBackStack;
  final double totalLayStack;
  final double totalStack;
  final double totalBackMtm;
  final double totalLayMtm;
  final double totalMtm;
  final double marginBack;
  final double marginLay;
  final double marginTotal;
  final double commission;

  LifeTimeReportDetail({
    required this.name,
    required this.layCount,
    required this.backCount,
    required this.totalBackStack,
    required this.totalLayStack,
    required this.totalStack,
    required this.totalBackMtm,
    required this.totalLayMtm,
    required this.totalMtm,
    required this.marginBack,
    required this.marginLay,
    required this.marginTotal,
    required this.commission,
  });

  factory LifeTimeReportDetail.fromJson(Map<String, dynamic> json) => LifeTimeReportDetail(
        name: (json['name'] ?? '').toString().toUpperCase(),
        layCount: (json['layCount'] as num).toDouble(),
        backCount: (json['backCount'] as num).toDouble(),
        totalBackStack: (json['totalBackStack'] as num).toDouble(),
        totalLayStack: (json['totalLayStack'] as num).toDouble(),
        totalStack: (json['totalStack'] as num).toDouble(),
        totalBackMtm: (json['totalBackMtm'] as num).toDouble(),
        totalLayMtm: (json['totalLayMtm'] as num).toDouble(),
        totalMtm: (json['totalMtm'] as num).toDouble(),
        marginBack: (json['marginBack'] as num).toDouble(),
        marginLay: (json['marginLay'] as num).toDouble(),
        marginTotal: (json['marginTotal'] as num).toDouble(),
        commission: (json['commission'] as num).toDouble(),
      );
}
