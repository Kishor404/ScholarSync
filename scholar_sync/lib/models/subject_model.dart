import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 4) // keep typeId exactly the same
class SubjectModel extends HiveObject {
  @HiveField(0)
  int semester;

  @HiveField(1)
  String name;

  @HiveField(2)
  double credits;

  @HiveField(3)
  String grade; // "O", "A+", "A", etc.

  @HiveField(4, defaultValue: 'None')
  String code;

  // Example: "21^25$CB^CS^AD$3^4^5"
  // Meaning: regulations = [21, 25], dept = [CB, CS, AD], sem = [3, 4, 5]
  @HiveField(5, defaultValue: '')
  String metaMapping;

  @HiveField(6, defaultValue: 'core')
  String category; 
  // "core" | "pe" | "oe"

  SubjectModel({
    required this.semester,
    required this.name,
    required this.credits,
    this.grade = '',
    required this.code,
    required this.metaMapping,
    this.category='core'
  });
}
