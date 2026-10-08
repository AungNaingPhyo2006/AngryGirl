// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerDataAdapter extends TypeAdapter<PlayerData> {
  @override
  final int typeId = 0;

  @override
  PlayerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerData()
      ..highScore = fields[1] as int
      .._diamonds = fields[2] as int? ?? 0
      .._upgradeLevels = (fields[3] as Map?)?.cast<String, int>()
      .._ownedSkins = (fields[4] as List?)?.cast<String>()
      .._selectedSkin = fields[5] as String?
      .._ownedBackgrounds = (fields[6] as List?)?.cast<String>()
      .._selectedBackground = fields[7] as String?
      .._consumables = (fields[8] as Map?)?.cast<String, int>()
      .._ownedCosmetics = (fields[9] as List?)?.cast<String>()
      .._selectedCosmetics = (fields[10] as Map?)?.cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, PlayerData obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.highScore)
      ..writeByte(2)
      ..write(obj._diamonds)
      ..writeByte(3)
      ..write(obj._upgradeLevels)
      ..writeByte(4)
      ..write(obj._ownedSkins)
      ..writeByte(5)
      ..write(obj._selectedSkin)
      ..writeByte(6)
      ..write(obj._ownedBackgrounds)
      ..writeByte(7)
      ..write(obj._selectedBackground)
      ..writeByte(8)
      ..write(obj._consumables)
      ..writeByte(9)
      ..write(obj._ownedCosmetics)
      ..writeByte(10)
      ..write(obj._selectedCosmetics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
