import 'package:hive/hive.dart';

part 'internal_mark_model.g.dart';

@HiveType(typeId: 7)
class InternalMarkModel extends HiveObject {
  @HiveField(0)
  int semester;

  @HiveField(1)
  int internalNo;

  @HiveField(2)
  String subjectCode;

  @HiveField(3)
  double marks; // obtained marks

  @HiveField(4)
  double maxMarks; // e.g. 50, 40

  InternalMarkModel({
    required this.semester,
    required this.internalNo,
    required this.subjectCode,
    required this.marks,
    required this.maxMarks,
  });
}
