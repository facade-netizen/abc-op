// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaveLoginTokenModelAdapter extends TypeAdapter<SaveLoginTokenModel> {
  @override
  final int typeId = 1;

  @override
  SaveLoginTokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaveLoginTokenModel(
      token: fields[0] as String?,
      refreshToken: fields[1] as String?,
      validTill: fields[2] as String?,
      savedAt: fields[3] as DateTime?,
      userId: fields[4] as String?,
      role: fields[5] as String?,
      userName: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SaveLoginTokenModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.validTill)
      ..writeByte(3)
      ..write(obj.savedAt)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveLoginTokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
