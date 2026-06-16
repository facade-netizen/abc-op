class MarketPlModel {
  final int status;
  final List<MarketPlData> data;
  final String message;

  MarketPlModel({required this.status, required this.data, required this.message});

  factory MarketPlModel.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<MarketPlData> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => MarketPlData.fromJson(e as Map<String, dynamic>)).toList();
    } else if (dataJson is Map<String, dynamic>) {
      parsedData = [MarketPlData.fromJson(dataJson)];
    } else {
      parsedData = [];
    }

    return MarketPlModel(status: json['status'] as int? ?? 0, data: parsedData, message: json['message']?.toString() ?? '');
  }
}

class MarketPlData {
  final String username;
  final String userRole;
  final List<SportWiseModel> sportWise;
  final List<MarketPlData> childs;
  final String owner;
  final String userId;
  final double stake;
  final double win;
  final double loss;
  final double winLoss;
  final double commission;
  final double totalPnl;
  final String wLid;
  final String site;
  final double rebate;

  // AgentLevels for all types
  final AgentLevel maAgent;
  final AgentLevel supAgent;
  final AgentLevel ssAgent;
  final AgentLevel wlAgent;

  MarketPlData({
    required this.username,
    required this.userRole,
    required this.sportWise,
    required this.childs,
    required this.owner,
    required this.userId,
    required this.stake,
    required this.win,
    required this.loss,
    required this.winLoss,
    required this.commission,
    required this.totalPnl,
    required this.wLid,
    required this.site,
    required this.rebate,
    required this.maAgent,
    required this.supAgent,
    required this.ssAgent,
    required this.wlAgent,
  });

  factory MarketPlData.fromJson(Map<String, dynamic> json) {
    return MarketPlData(
      userRole: json['title'] ?? '',
      username: json['username'] ?? '',
      sportWise: (json['sportWise'] as List? ?? []).map((e) => SportWiseModel.fromJson(e)).toList(),
      childs: (json['childs'] as List? ?? []).map((e) => MarketPlData.fromJson(e)).toList(),
      owner: json['owner'] ?? '',
      userId: json['userId'] ?? '',
      stake: (json['stake'] ?? 0).toDouble(),
      win: (json['win'] ?? 0).toDouble(),
      loss: (json['loss'] ?? 0).toDouble(),
      winLoss: (json['winLoss'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPnl: (json['totalPnl'] ?? 0).toDouble(),
      wLid: json['wLid'] ?? '',
      site: (json['site'] ?? '').toString().toUpperCase(),
      rebate: (json['rebate'] ?? 0).toDouble(),
      maAgent: json['maAgent'] != null ? AgentLevel.fromJson(json['maAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      supAgent: json['supAgent'] != null ? AgentLevel.fromJson(json['supAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      ssAgent: json['ssAgent'] != null ? AgentLevel.fromJson(json['ssAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      wlAgent: json['wlAgent'] != null ? AgentLevel.fromJson(json['wlAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
    );
  }
}

class SportWiseModel {
  final String sportName;
  final double stake;
  final double win;
  final double loss;
  final double winLoss;
  final double commission;
  final double totalPnl;
  final String wLid;
  final String site;
  final double rebate;

  // AgentLevels for all types
  final AgentLevel maAgent;
  final AgentLevel supAgent;
  final AgentLevel ssAgent;
  final AgentLevel wlAgent;
  SportWiseModel({
    required this.sportName,
    required this.stake,
    required this.win,
    required this.loss,
    required this.winLoss,
    required this.commission,
    required this.totalPnl,
    required this.wLid,
    required this.site,
    required this.rebate,
    required this.maAgent,
    required this.supAgent,
    required this.ssAgent,
    required this.wlAgent,
  });

  factory SportWiseModel.fromJson(Map<String, dynamic> json) {
    return SportWiseModel(
      sportName: json['sportName'] ?? '',
      stake: (json['stake'] ?? 0).toDouble(),
      win: (json['win'] ?? 0).toDouble(),
      loss: (json['loss'] ?? 0).toDouble(),
      winLoss: (json['winLoss'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPnl: (json['totalPnl'] ?? 0).toDouble(),
      wLid: json['wLid'] ?? '',
      site: (json['site'] ?? '').toString().toUpperCase(),
      rebate: (json['rebate'] ?? 0).toDouble(),
      maAgent: json['maAgent'] != null ? AgentLevel.fromJson(json['maAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      supAgent: json['supAgent'] != null ? AgentLevel.fromJson(json['supAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      ssAgent: json['ssAgent'] != null ? AgentLevel.fromJson(json['ssAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
      wlAgent: json['wlAgent'] != null ? AgentLevel.fromJson(json['wlAgent']) : const AgentLevel(winLoss: 0, comm: 0, rebate: 0),
    );
  }
}

class AgentLevel {
  final double winLoss;
  final double comm;
  final double rebate;

  const AgentLevel({required this.winLoss, required this.comm, required this.rebate});

  factory AgentLevel.fromJson(Map<String, dynamic> json) {
    return AgentLevel(winLoss: (json['winLoss'] ?? 0).toDouble(), comm: (json['comm'] ?? 0).toDouble(), rebate: (json['rebate'] ?? 0).toDouble());
  }
}
