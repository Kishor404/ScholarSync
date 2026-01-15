import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';


import '../models/subject_model.dart';
import '../models/internal_model.dart';
import '../models/internal_mark_model.dart';
import '../models/internal_gpa_model.dart';


class InternalCalcController extends GetxController {
  late Box<SubjectModel> subjectBox;
  late Box<InternalModel> internalBox;
  late Box<InternalMarkModel> markBox;
  late Box<InternalGpaModel> gpaBox;

  final internals = <InternalModel>[].obs;
  final markList = <InternalMarkModel>[].obs;
  final gpas = <InternalGpaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    subjectBox = Hive.box<SubjectModel>('subjectBox');
    internalBox = Hive.box<InternalModel>('internalBox');
    markBox = Hive.box<InternalMarkModel>('internalMarkBox');
    gpaBox = Hive.box<InternalGpaModel>('internalGpaBox');
    
    _loadData();
    ensureDefaultInternals(1);
  }

  void _loadData() {
    internals.assignAll(internalBox.values);
    markList.assignAll(markBox.values);
    gpas.assignAll(gpaBox.values);
  }

  // --------------------------------------------------
  // SEMESTER SUMMARY
  // --------------------------------------------------

  Map<String, double> getSemesterSummary(int semester) {
    final semesterInternals =
        internals.where((i) => i.semester == semester).toList();

    if (semesterInternals.isEmpty) {
      return {
        'avgGpa': 0,
        'avgObtained': 0,
        'avgMax': 0,
      };
    }

    double gpaSum = 0;
    int gpaCount = 0;

    double obtainedSum = 0;
    double maxSum = 0;
    int markCount = 0;

    for (final internal in semesterInternals) {
      // ---- GPA ----
      final gpaModel = gpas.firstWhereOrNull(
        (g) =>
            g.semester == semester &&
            g.internalNo == internal.internalNo,
      );

      if (gpaModel != null) {
        gpaSum += gpaModel.gpa;
        gpaCount++;
      }

      // ---- Marks ----
      final marks = markList.where(
        (m) =>
            m.semester == semester &&
            m.internalNo == internal.internalNo,
      );

      if (marks.isNotEmpty) {
        double obtained = 0;
        double max = 0;

        for (final m in marks) {
          obtained += m.marks;
          max += m.maxMarks;
        }

        obtainedSum += obtained;
        maxSum += max;
        markCount++;
      }
    }

    return {
      'avgGpa': gpaCount == 0 ? 0 : gpaSum / gpaCount,
      'avgObtained': markCount == 0 ? 0 : obtainedSum / markCount,
      'avgMax': markCount == 0 ? 0 : maxSum / markCount,
    };
  }


  // --------------------------------------------------
  // Internal CRUD
  // --------------------------------------------------

  Future<void> addInternal(int semester, String name) async {
    final internalNo =
        internals.where((i) => i.semester == semester).length + 1;

    final internal = InternalModel(
      semester: semester,
      internalNo: internalNo,
      name: name,
    );

    await internalBox.add(internal);
    internals.add(internal);
  }

  // --------------------------------------------------
  // Marks
  // --------------------------------------------------

  Map<String, double> getTotalMarks({
    required int semester,
    required int internalNo,
  }) {
    final marks = markList.where(
      (m) => m.semester == semester && m.internalNo == internalNo,
    );

    double obtained = 0;
    double max = 0;

    for (final m in marks) {
      obtained += m.marks;
      max += m.maxMarks; // will be 100 per subject
    }

    return {
      'obtained': obtained,
      'max': max,
    };
  }


  Future<void> addOrUpdateMark({
    required int semester,
    required int internalNo,
    required SubjectModel subject,
    required double obtainedMarks,
    required double maxMarks,
  }) async {
    final existing = markList.firstWhereOrNull(
      (m) =>
          m.semester == semester &&
          m.internalNo == internalNo &&
          m.subjectCode == subject.code,
    );

    if (existing != null) {
      existing.marks = obtainedMarks;
      existing.maxMarks = maxMarks;
      await existing.save();
    } else {
      final mark = InternalMarkModel(
        semester: semester,
        internalNo: internalNo,
        subjectCode: subject.code,
        marks: obtainedMarks,
        maxMarks: maxMarks,
      );

      await markBox.add(mark);
      markList.add(mark);
    }

    markList.refresh(); // 🔥 CRITICAL

    await calculateInternalGpa(semester, internalNo);
  }


  // --------------------------------------------------
  // GPA Calculation
  // --------------------------------------------------

  double _finalPointFromMarks(double mark) {
    if (mark >=90) return 10;
    if (mark >= 80) return 9;
    if (mark >= 70) return 8;
    if (mark >= 60) return 7;
    if (mark >= 50) return 6;
    if (mark >= 40) return 5;
    return 0;
  }

  Future<void> ensureDefaultInternals(int semester) async {
    final existing = internals
        .where((i) => i.semester == semester)
        .toList();

    // If already exists, do nothing
    if (existing.isNotEmpty) return;

    // Create Internal 1
    final internal1 = InternalModel(
      semester: semester,
      internalNo: 1,
      name: "Internal 1",
    );

    // Create Internal 2
    final internal2 = InternalModel(
      semester: semester,
      internalNo: 2,
      name: "Internal 2",
    );

    await internalBox.add(internal1);
    await internalBox.add(internal2);

    internals.addAll([internal1, internal2]);
  }



  Future<void> calculateInternalGpa(int semester, int internalNo) async {
    final semesterSubjects =
        subjectBox.values.where((s) => s.semester == semester).toList();

    final internalMarks = markList.where(
      (m) => m.semester == semester && m.internalNo == internalNo,
    );

    double totalCredits = 0;
    double totalPoints = 0;

    for (final sub in semesterSubjects) {
      final mark = internalMarks.firstWhereOrNull(
        (m) => m.subjectCode == sub.code,
      );

      if (mark == null) continue;

      if (!subjectBox.values.any((s) => s.code == mark.subjectCode)) {
        continue; // subject deleted
      }


      final fPoint = _finalPointFromMarks(mark.marks);

      totalCredits += sub.credits;
      totalPoints += fPoint * sub.credits;

    }

    if (totalCredits == 0) {
      final existing = gpas.firstWhereOrNull(
        (g) => g.semester == semester && g.internalNo == internalNo,
      );

      if (existing != null) {
        await existing.delete();
        gpas.remove(existing);
        gpas.refresh();
      }

      return;
    }


    final gpa = totalPoints / totalCredits;

    final existing = gpas.firstWhereOrNull(
      (g) => g.semester == semester && g.internalNo == internalNo,
    );

    if (existing != null) {
      existing.gpa = gpa;
      await existing.save();
      gpas.refresh();
    } else {
      final gpaModel = InternalGpaModel(
        semester: semester,
        internalNo: internalNo,
        gpa: gpa,
      );

      await gpaBox.add(gpaModel);
      gpas.add(gpaModel);
    }
  }
  Future<void> deleteInternal({
    required int semester,
    required int internalNo,
  }) async {
    // 1️⃣ Delete Internal model
    final internal = internals.firstWhereOrNull(
      (i) => i.semester == semester && i.internalNo == internalNo,
    );

    if (internal != null) {
      await internal.delete();
      internals.remove(internal);
    }

    // 2️⃣ Delete related marks
    final marksToDelete = markList
        .where((m) =>
            m.semester == semester &&
            m.internalNo == internalNo)
        .toList();

    for (final m in marksToDelete) {
      await m.delete();
    }
    markList.removeWhere(
      (m) =>
          m.semester == semester &&
          m.internalNo == internalNo,
    );
    markList.refresh();

    // 3️⃣ Delete GPA
    final gpa = gpas.firstWhereOrNull(
      (g) => g.semester == semester && g.internalNo == internalNo,
    );

    if (gpa != null) {
      await gpa.delete();
      gpas.remove(gpa);
      gpas.refresh();
    }
  }

  Future<void> clearAllInternalData() async {
    // 1️⃣ Delete all marks
    await markBox.clear();
    markList.clear();

    // 2️⃣ Delete all internal GPAs
    await gpaBox.clear();
    gpas.clear();
  }


}
