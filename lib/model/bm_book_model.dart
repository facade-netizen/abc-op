import 'package:flutter/material.dart';

class BMBookResponse {
  final int status;
  final List<BMBookData> data;
  final String message;

  BMBookResponse({required this.status, required this.data, required this.message});

  factory BMBookResponse.fromJson(Map<dynamic, dynamic> json) {
    return BMBookResponse(status: json['status'] ?? 0, data: (json['data'] as List?)?.map((e) => BMBookData.fromJson(e)).toList() ?? [], message: json['message'] ?? "");
  }
}

class BMBookData {
  final String name;
  final String id;
  final double net;
  final List<BMBookRunner> runners;
  final List<UplineData> upLines;

  BMBookData({
    required this.name,
    required this.net,
    required this.runners,
    required this.upLines,
    required this.id,
  });

  factory BMBookData.fromJson(Map<String, dynamic> json) {
    return BMBookData(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      net: json['net'] ?? 0.0,
      runners: (json['runners'] as List? ?? []).map((item) => BMBookRunner.fromJson(item)).toList(),
      upLines: (json['upLine'] as List? ?? []).map((item) => UplineData.fromJson(item)).toList(),
    );
  }
}

class BMBookRunner {
  final String runnerId;
  final String runnerName;
  final double net;

  BMBookRunner({required this.runnerId, required this.runnerName, required this.net});

  factory BMBookRunner.fromJson(Map<String, dynamic> json) {
    return BMBookRunner(
      runnerId: json['runnerId'] ?? '',
      runnerName: json['runnerName'] ?? '',
      net: json['net'] ?? 0.0,
    );
  }
}

class UplineData {
  final String name;
  final String title;
  final Color badgeColor;
  UplineData({
    required this.name,
    required this.title,
    required this.badgeColor,
  });
  factory UplineData.fromJson(Map<String, dynamic> json) {
    return UplineData(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      badgeColor: getBadgeColor(json['title'] ?? ''),
    );
  }
}

Color getBadgeColor(String title) {
  switch (title.toLowerCase()) {
    case 'one':
      return const Color(0xFFD65C5C);
    case 'ss':
      return const Color(0xFFA671B8);
    case 'sup':
      return const Color(0xFF87C275);
    case 'ma':
      return const Color(0xFF568bc8);
    case 'pl':
      return const Color(0xFF4A90E2);
    default:
      return const Color(0xFF568bc8); // Default color for unknown titles
  }
}
