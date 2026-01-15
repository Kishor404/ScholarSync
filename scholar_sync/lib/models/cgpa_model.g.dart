// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cgpa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CgpaModelAdapter extends TypeAdapter<CgpaModel> {
  @override
  final int typeId = 3;

  @override
  CgpaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CgpaModel(
      cgpa: fields[0] as double,
      currentSem: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CgpaModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cgpa)
      ..writeByte(1)
      ..write(obj.currentSem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CgpaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
