import 'package:hive/hive.dart';

part 'internal_model.g.dart';

@HiveType(typeId: 6)
class InternalModel extends HiveObject {
  @HiveField(0)
  int semester; // e.g. 3

  @HiveField(1)
  int internalNo; // 1, 2, 3...

  @HiveField(2)
  String name; // "Internal 1", "Model Test"

  InternalModel({
    required this.semester,
    required this.internalNo,
    required this.name,
  });
}
