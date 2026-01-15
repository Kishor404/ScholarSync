import 'package:hive/hive.dart';

part 'cgpa_model.g.dart';

@HiveType(typeId: 3) // make sure this ID is unique across your app
class CgpaModel extends HiveObject {
  /// Overall CGPA value
  @HiveField(0)
  double cgpa;

  /// Latest / current semester up to which this CGPA is calculated
  @HiveField(1)
  int currentSem;

  CgpaModel({
    required this.cgpa,
    required this.currentSem,
  });
}
