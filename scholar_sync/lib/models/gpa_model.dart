import 'package:hive/hive.dart';

part 'gpa_model.g.dart';

@HiveType(typeId: 5) // unique ID
class GpaModel extends HiveObject {
  @HiveField(0)
  int semester;

  @HiveField(1)
  double gpa;

  GpaModel({
    required this.semester,
    required this.gpa,
  });
}
