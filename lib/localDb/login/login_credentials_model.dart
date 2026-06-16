import 'package:hive/hive.dart';

part 'login_credentials_model.g.dart';

@HiveType(typeId: 2)
class LoginCredentialsModel {
  LoginCredentialsModel({this.userId, this.password, this.savedAt});

  @HiveField(0)
  String? userId;

  @HiveField(1)
  String? password;

  @HiveField(2)
  DateTime? savedAt;

  factory LoginCredentialsModel.fromMap(Map<String, dynamic> data) {
    return LoginCredentialsModel(userId: data['userId'], password: data['password'], savedAt: data['savedAt']);
  }
}
