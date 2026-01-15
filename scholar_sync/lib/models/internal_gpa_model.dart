import 'package:hive/hive.dart';

part 'internal_gpa_model.g.dart';

@HiveType(typeId: 8)
class InternalGpaModel extends HiveObject {
  @HiveField(0)
  int semester;

  @HiveField(1)
  int internalNo;

  @HiveField(2)
  double gpa;

  InternalGpaModel({
    required this.semester,
    required this.internalNo,
    required this.gpa,
  });
}
