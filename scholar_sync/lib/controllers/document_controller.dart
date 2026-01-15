import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/course_model.dart';
import '../models/document_model.dart';

class DocumentController extends GetxController {
  static const _boxName = 'documentsBoxV2';

  late Box<DocumentModel> _box;

  final documents = <DocumentModel>[].obs;

  /// Categories shown in the horizontal bar
  final categories = <String>['All', 'Important', 'Course'].obs;

  final selectedCategory = 'All'.obs;
  final showFavoritesOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box<DocumentModel>(_boxName);
    _loadDocuments();
    syncFromCourses(); 
  }

  void _loadDocuments() {
    documents.assignAll(_box.values);

    // Build category list from existing docs
    for (final doc in documents) {
      for (final c in doc.categories) {
        if (!categories.contains(c)) {
          categories.add(c);
        }
      }
    }
  }

  List<DocumentModel> get filteredDocuments {
    return documents.where((doc) {
      if (selectedCategory.value != 'All' &&
          !doc.categories.contains(selectedCategory.value)) {
        return false;
      }
      if (showFavoritesOnly.value && !doc.isFav) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> addDocument(DocumentModel doc) async {
    await _box.add(doc);
    documents.add(doc);

    for (final c in doc.categories) {
      if (!categories.contains(c)) {
        categories.add(c);
      }
    }
  }

  Future<void> updateDocument(DocumentModel doc) async {
    await doc.save();
    documents.refresh();

    // Rebuild categories list
    for (final c in doc.categories) {
      if (!categories.contains(c)) {
        categories.add(c);
      }
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    await doc.delete();            // remove from Hive
    documents.remove(doc);         // remove from list
    documents.refresh();
  }


  void toggleFavorite(DocumentModel doc) {
    doc.isFav = !doc.isFav;
    doc.save();
    documents.refresh();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleFavoritesFilter() {
    showFavoritesOnly.value = !showFavoritesOnly.value;
  }

  void addCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    if (!categories.contains(trimmed)) {
      categories.add(trimmed);
    }
  }

  Future<void> deleteCourseDocumentsByPath(String path) async {
    // Delete from Hive box
    final toDelete = _box.values.where(
      (d) => d.path == path && d.categories.contains('Course'),
    );

    for (final doc in toDelete.toList()) {
      await doc.delete(); // HiveObject.delete()
    }

    // Delete from in-memory list
    documents.removeWhere(
      (d) => d.path == path && d.categories.contains('Course'),
    );
    documents.refresh();
  }

  Future<void> clearAllDocuments() async {
    await _box.clear();
    documents.clear();

    // Reset categories to defaults
    categories
      ..clear()
      ..addAll(['All', 'Important', 'Course']);

    selectedCategory.value = 'All';
    showFavoritesOnly.value = false;
  }


  Future<void> syncFromCourses() async {
    final courseBox = Hive.box<CourseModel>('courseBox');

    // 1) Collect all valid certificate paths from existing courses
    final validCoursePaths = <String>{};
    for (final course in courseBox.values) {
      if (course.certificationPath.isNotEmpty) {
        validCoursePaths.add(course.certificationPath);
      }
    }

    // 2) Remove orphan "Course" documents
    final orphanDocs = documents
        .where(
          (d) => d.categories.contains('Course') &&
                !validCoursePaths.contains(d.path),
        )
        .toList();

    for (final doc in orphanDocs) {
      await doc.delete();     // remove from Hive
      documents.remove(doc);  // remove from memory
    }

    // 3) Ensure the "Course" category exists
    if (!categories.contains('Course')) {
      categories.add('Course');
    }

    // 4) Add missing documents for existing courses
    for (final course in courseBox.values) {
      final certPath = course.certificationPath;
      if (certPath.isEmpty) continue;

      final exists = documents.any(
        (d) =>
            d.path == certPath &&
            d.categories.contains('Course'),
      );

      if (!exists) {
        final type = certPath.split('.').last.toLowerCase();

        final newDoc = DocumentModel(
          title: course.courseName,
          path: certPath,
          type: type,
          isFav: false,
          categories: ['Course'],
        );

        await _box.add(newDoc);
        documents.add(newDoc);
      }
    }

    documents.refresh();
  }


}
