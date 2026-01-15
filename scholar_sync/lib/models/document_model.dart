import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 1)
class DocumentModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String path;          // file path

  @HiveField(2)
  String type;          // extension like 'pdf', 'jpg', 'png'

  @HiveField(3)
  bool isFav;           // true / false

  @HiveField(4)
  List<String> categories; // a document can have many categories

  DocumentModel({
    required this.title,
    required this.path,
    required this.type,
    this.isFav = false,
    required this.categories,
  });
}
