// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InternalModelAdapter extends TypeAdapter<InternalModel> {
  @override
  final int typeId = 6;

  @override
  InternalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InternalModel(
      semester: fields[0] as int,
      internalNo: fields[1] as int,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InternalModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.semester)
      ..writeByte(1)
      ..write(obj.internalNo)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
