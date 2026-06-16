class AgencyResponse {
  final int status;
  final List<AgencyModel> data;
  final String message;

  AgencyResponse({required this.status, required this.data, required this.message});

  factory AgencyResponse.fromJson(Map<dynamic, dynamic> json) {
    return AgencyResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List? ?? []).map((e) => AgencyModel.fromJson(e)).toList(),
      message: json['message'] ?? '',
    );
  }
}

class AgencyModel {
  final String id;
  final String userName;
  final String role;
  final String upLine;
  final String userStatus;
  final String wlName;
  final double creditRef;
  final String createdTime;
  final double commissionRate;
  final double netPoint;
  final double pnl;
  final double balancePoint;
  final double commission;
  final double exposure;
  final double exposureLimit;
  final double casinoBalance;
  bool systemLocked;
  bool systemSuspended;
  bool passLocked;
  final String currency;
  final String sysLockedUpdator;
  final String sysSuspendedUpdator;
  final double todayPnl;
  final double agentBalance;
  final bool isPlayer;

  AgencyModel({
    required this.id,
    required this.userName,
    required this.role,
    required this.upLine,
    required this.userStatus,
    required this.wlName,
    required this.creditRef,
    required this.createdTime,
    required this.commissionRate,
    required this.netPoint,
    required this.pnl,
    required this.balancePoint,
    required this.commission,
    required this.exposure,
    required this.casinoBalance,
    required this.exposureLimit,
    this.systemLocked = false,
    this.systemSuspended = false,
    this.passLocked = false,
    required this.currency,
    required this.sysLockedUpdator,
    required this.sysSuspendedUpdator,
    required this.todayPnl,
    required this.agentBalance,
    required this.isPlayer,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }
    final isClient = json['role']?.toString().toLowerCase() == 'client';
    //availableBalance= balancePoint-exposure - commission + pnl
    double availableBalance = !isClient
        ? (parseDouble(json['balancePoint']) - parseDouble(json['exposure']) - parseDouble(json['commission']) + parseDouble(json['pnl']))
        : parseDouble(json['balancePoint']);
    //
    // double validPnl = kDebugMode ? (parseDouble(json['pnl']) + parseDouble(json['casinopnl'])) - parseDouble(json['commission']) : parseDouble(json['pnl']);
    //validAgentBalance = balancePoint + exposure
    double validAgentBalance = !isClient ? (availableBalance + parseDouble(json['exposure'])) : 0.0;
    return AgencyModel(
      isPlayer: isClient,
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      role: getRoleFromUserLevel(json['role'] ?? ''),
      upLine: json['upLine'] ?? '',
      userStatus: json['userStatus'] ?? '',
      wlName: (json['wlName'] ?? '').toString().toUpperCase(),
      creditRef: parseDouble(json['creditRef']),
      createdTime: json['createdTime'] ?? '',
      commissionRate: parseDouble(json['commissionRate']),
      netPoint: parseDouble(json['netPoint']),
      pnl: parseDouble(json['pnl']),
      commission: parseDouble(json['commission']),
      balancePoint: availableBalance,
      exposure: parseDouble(json['exposure']),
      casinoBalance: parseDouble(json['casinoBalance']),
      exposureLimit: parseDouble(json['exposureLimit']),
      currency: 'INR',
      systemLocked: json['systemLock'] ?? false,
      systemSuspended: json['suspended'] ?? false,
      passLocked: json['passLock'] ?? false,
      sysLockedUpdator: json['sytemlockUpdater'] ?? '',
      sysSuspendedUpdator: json['suspendUpdater'] ?? '',
      todayPnl: parseDouble(json['todayPnl']),
      agentBalance: validAgentBalance,
    );
  }
}

String getRoleFromUserLevel(String userLevel) {
  switch (userLevel) {
    case "supersuperAdmin":
      return "Senior Super";
    case "superAdmin":
      return "Super";
    case "master":
      return "Master Agent";
    case "client":
      return "Player";
    default:
      return "-";
  }
}
