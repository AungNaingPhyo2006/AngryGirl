// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      .._bgm = fields[0] as bool
      .._sfx = fields[1] as bool
      .._enemyNames = (fields[2] as Map?)?.cast<String, String>()
      .._language = fields[3] as String?
      .._hudGuideSeen = fields[4] as bool?
      .._tutorialDone = fields[5] as bool?;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj._bgm)
      ..writeByte(1)
      ..write(obj._sfx)
      ..writeByte(2)
      ..write(obj._enemyNames)
      ..writeByte(3)
      ..write(obj._language)
      ..writeByte(4)
      ..write(obj._hudGuideSeen)
      ..writeByte(5)
      ..write(obj._tutorialDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
