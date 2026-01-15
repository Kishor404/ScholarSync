// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GpaModelAdapter extends TypeAdapter<GpaModel> {
  @override
  final int typeId = 5;

  @override
  GpaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GpaModel(
      semester: fields[0] as int,
      gpa: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GpaModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.semester)
      ..writeByte(1)
      ..write(obj.gpa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
