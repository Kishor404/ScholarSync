// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_gpa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InternalGpaModelAdapter extends TypeAdapter<InternalGpaModel> {
  @override
  final int typeId = 8;

  @override
  InternalGpaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InternalGpaModel(
      semester: fields[0] as int,
      internalNo: fields[1] as int,
      gpa: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InternalGpaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.semester)
      ..writeByte(1)
      ..write(obj.internalNo)
      ..writeByte(2)
      ..write(obj.gpa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternalGpaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
