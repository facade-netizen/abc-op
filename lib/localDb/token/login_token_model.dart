import 'package:hive/hive.dart';

part 'login_token_model.g.dart';

@HiveType(typeId: 1)
class SaveLoginTokenModel {
  SaveLoginTokenModel({
    this.token,
    this.refreshToken,
    this.validTill,
    this.savedAt,
    this.userId,
    this.role,
    this.userName,
  });

  @HiveField(0)
  String? token;

  @HiveField(1)
  String? refreshToken;

  @HiveField(2)
  String? validTill;

  @HiveField(3)
  DateTime? savedAt;

  @HiveField(4)
  String? userId;

  @HiveField(5)
  String? role;

  @HiveField(6)
  String? userName;

  factory SaveLoginTokenModel.fromMap(Map<String, dynamic> data) {
    return SaveLoginTokenModel(
      token: data['token'],
      refreshToken: data['refreshToken'],
      validTill: data['validTill'],
      savedAt: data['savedAt'],
      userId: data['userId'],
      role: data['role'],
      userName: data['userName'],
    );
  }
}
