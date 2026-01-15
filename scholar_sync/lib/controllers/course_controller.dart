import 'package:get/get.dart';
import '../models/course_model.dart';
import 'package:hive/hive.dart';
import './document_controller.dart';


class CourseController extends GetxController {
  var courseList = <CourseModel>[].obs;

  // This will hold either: 'Completed', 'Pending', 'All', or a category name
  var selectedFilter = 'All'.obs;

  // All categories used in courses
  var categoryList = <String>[].obs;

  late Box<CourseModel> courseBox;

  @override
  void onInit() {
    super.onInit();
    courseBox = Hive.box<CourseModel>('courseBox');
    loadCourse();
  }

  void loadCourse() {
    courseList.value = courseBox.values.toList();
    _refreshCategories();
  }

  void addCourse(CourseModel course) {
    courseBox.add(course);
    loadCourse();
    Get.find<DocumentController>().syncFromCourses();
  }

  void updateCourse(int index, CourseModel newCourse) {
    courseBox.putAt(index, newCourse);
    loadCourse();
    Get.find<DocumentController>().syncFromCourses();
  }

  // void deleteCourse(int index) {
  //   final course = courseList[index];
  //   final docCtrl = Get.find<DocumentController>();
  //   docCtrl.documents.removeWhere((d) =>
  //       d.path == course.certificationPath);
  //   docCtrl.documents.refresh();

  //   courseBox.deleteAt(index);
  //   loadCourse();
  // }

  void deleteCourse(int index) {
    final course = courseList[index];
    final certPath = course.certificationPath;

    // delete from courseBox
    courseBox.deleteAt(index);
    loadCourse();

    // also delete linked document from vault
    if (certPath.isNotEmpty) {
      final docCtrl = Get.find<DocumentController>();
      docCtrl.deleteCourseDocumentsByPath(certPath);
    }
  }

  Future<void> clearAllCourses() async {
    await courseBox.clear();
    courseList.clear();
    _refreshCategories();

    // Also sync Vault to remove course-linked docs
    if (Get.isRegistered<DocumentController>()) {
      await Get.find<DocumentController>().syncFromCourses();
    }
  }


  // ---------- Categories ----------
  void _refreshCategories() {
    final set = <String>{};

    for (final c in courseList) {
      final cats = c.categories;
      set.addAll(cats);
    }

    categoryList.value = set.toList()..sort();
  }

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (!categoryList.contains(trimmed)) {
      categoryList.add(trimmed);
      categoryList.sort();
    }
  }

  // ---------- Stats ----------
  int get completedCount =>
      courseList.where((c) => c.isCompleted).length;

  int get pendingCount => courseList.length - completedCount;

  // ---------- Filtered list ----------
  List<CourseModel> get filteredCourses {
    final filter = selectedFilter.value;
    Iterable<CourseModel> list = courseList;

    if (filter == 'Completed') {
      list = list.where((c) => c.isCompleted);
    } else if (filter == 'Pending') {
      list = list.where((c) => !c.isCompleted);
    } else if (filter == 'All') {
      // no status filter
    } else {
      // treat filter as category name
      list = list.where(
        (c) => (c.categories).contains(filter),
      );
    }

    return list.toList();
  }
}
