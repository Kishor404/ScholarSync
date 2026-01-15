// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_mark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InternalMarkModelAdapter extends TypeAdapter<InternalMarkModel> {
  @override
  final int typeId = 7;

  @override
  InternalMarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InternalMarkModel(
      semester: fields[0] as int,
      internalNo: fields[1] as int,
      subjectCode: fields[2] as String,
      marks: fields[3] as double,
      maxMarks: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InternalMarkModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.semester)
      ..writeByte(1)
      ..write(obj.internalNo)
      ..writeByte(2)
      ..write(obj.subjectCode)
      ..writeByte(3)
      ..write(obj.marks)
      ..writeByte(4)
      ..write(obj.maxMarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternalMarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
