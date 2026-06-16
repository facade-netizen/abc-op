// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_credentials_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginCredentialsModelAdapter extends TypeAdapter<LoginCredentialsModel> {
  @override
  final int typeId = 2;

  @override
  LoginCredentialsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginCredentialsModel(
      userId: fields[0] as String?,
      password: fields[1] as String?,
      savedAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginCredentialsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginCredentialsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
