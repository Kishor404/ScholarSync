import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/subject_model.dart';
import '../models/gpa_model.dart';
import '../models/cgpa_model.dart';
import 'cgpa_controller.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import './internal_calc_controller.dart';

class CgpaCalcController extends GetxController {
  late Box<SubjectModel> subjectBox;
  late Box<GpaModel> gpaBox;

  /// All subjects (templates + those assigned to semesters)
  final subjects = <SubjectModel>[].obs;

  /// All GPA records (one per semester)
  final gpas = <GpaModel>[].obs;

  /// Current CGPA
  final cgpa = 0.0.obs;

  /// Grade → point mapping
  /// Adjust if your university uses a different scale
  final Map<String, double> gradePoints = {
    'O': 10,
    'A+': 9,
    'A': 8,
    'B+': 7,
    'B': 6,
    'C': 5,
    'U': 0,
    'RA': 0,
  };

  @override
  void onInit() {
    super.onInit();
    subjectBox = Hive.box<SubjectModel>('subjectBox');
    gpaBox = Hive.box<GpaModel>('gpaBox');
    _loadData();
    _seedTemplatesFromCsvIfEmpty();
  }

  // ----------------------------------------------------------------------------
  // CSV seeding (templates)
  // ----------------------------------------------------------------------------

  Future<void> _loadCsv({
    required String path,
    required String category,
  }) async {
    try {
      final csvString = await rootBundle.loadString(path);
      final lines = const LineSplitter().convert(csvString);

      for (int i = 1; i < lines.length; i++) {
        final parts = lines[i].split(',');
        if (parts.length < 4) continue;

        final subject = SubjectModel(
          semester: 0,
          code: parts[0].trim(),
          name: parts[1].trim(),
          credits: double.tryParse(parts[2]) ?? 0,
          metaMapping: parts[3].trim(),
          grade: '',
          category: category,
        );

        await subjectBox.add(subject);
        subjects.add(subject);
      }
    } catch (e) {
      //print("CSV load error ($path): $e");
    }
  }


  Future<void> _seedTemplatesFromCsvIfEmpty() async {
    final hasTemplates = subjects.any((s) => s.semester == 0);
    if (hasTemplates) return;

    await _loadCsv(
      path: 'assets/subjects.csv',
      category: 'core',
    );

    await _loadCsv(
      path: 'assets/professional_electives.csv',
      category: 'pe',
    );

    await _loadCsv(
      path: 'assets/open_electives.csv',
      category: 'oe',
    );
  }


  // ----------------------------------------------------------------------------

  void _loadData() {
    subjects.assignAll(subjectBox.values);
    gpas.assignAll(gpaBox.values);
    _recomputeCgpaFromSubjects();
  }

  /// Subjects in DB that are templates (semester == 0)
  List<SubjectModel> get templates =>
      subjects.where((s) => s.semester == 0).toList();

  /// GPA per semester as a map: sem → gpa
  Map<int, double> get gpaPerSem =>
      {for (final g in gpas) g.semester: g.gpa};

  // ---------------------------------------------------------------------------
  // CRUD & operations
  // ---------------------------------------------------------------------------

  /// Add a subject directly to a semester (manual add dialog)
  Future<void> addSubject({
    required String name,
    required String code,
    required double credits,
    required int semester,
    required String grade,
  }) async {
    if (code.trim().isEmpty) {
      throw ArgumentError("Course code is required");
    }

    final subject = SubjectModel(
      semester: semester,
      name: name,
      credits: credits,
      grade: grade,
      code: code.trim(),
      metaMapping: '', // manual subjects: no meta-mapping
    );

    await subjectBox.add(subject);
    subjects.add(subject);
    await recalculateAll();
  }

  bool subjectExists({
    required String code,
    required int semester,
  }) {
    return subjects.any(
      (s) =>
          s.code.trim().toLowerCase() ==
          code.trim().toLowerCase() &&
          s.semester == semester,
    );
  }


  /// Add subject for a semester from a template (template has semester = 0)
  Future<void> addSubjectFromTemplate(
    SubjectModel template,
    int semester,
  ) async {
    if (template.code.trim().isEmpty) {
      // Should normally never happen after you clean templates
      throw ArgumentError("Template must have a course code");
    }

    final subject = SubjectModel(
      semester: semester,
      name: template.name,
      credits: template.credits,
      grade: '',
      code: template.code.trim(),
      metaMapping: template.metaMapping, // carry over for filtering
    );

    await subjectBox.add(subject);
    subjects.add(subject);
    await recalculateAll();
  }

  /// Remove a subject from a semester
  Future<void> removeSubject(SubjectModel subject) async {
    await subject.delete();       // remove from Hive
    subjects.remove(subject);    // remove from list
    await recalculateAll();
  }

  /// Update grade of a subject and recalculate GPAs/CGPA
  Future<void> updateSubjectGrade(
    SubjectModel subject,
    String newGrade,
  ) async {
    subject.grade = newGrade;
    await subject.save();
    await recalculateAll();
  }

  // ---------------------------------------------------------------------------
  // GPA & CGPA calculation
  // ---------------------------------------------------------------------------

  Future<void> recalculateAll() async {
    // Group subjects by semester (ignore templates and empty grades)
    final Map<int, List<SubjectModel>> bySem = {};
    for (final s in subjects) {
      if (s.semester <= 0) continue;      // ignore templates
      if (s.grade.isEmpty) continue;      // ignore not graded yet

      bySem.putIfAbsent(s.semester, () => []).add(s);
    }

    // Clear and recompute GPA box
    gpas.clear();
    await gpaBox.clear();

    int maxSem = 0;

    for (final entry in bySem.entries) {
      final sem = entry.key;
      maxSem = sem > maxSem ? sem : maxSem;
      final subs = entry.value;

      double totalCredits = 0;
      double totalPoints = 0;

      for (final s in subs) {
        final gp = gradePoints[s.grade.toUpperCase()] ?? 0;
        totalCredits += s.credits;
        totalPoints += gp * s.credits;
      }

      if (totalCredits == 0) continue;

      final gpa = totalPoints / totalCredits;
      final gpaModel = GpaModel(semester: sem, gpa: gpa);

      await gpaBox.put(sem, gpaModel); // key by semester
      gpas.add(gpaModel);
    }

    _recomputeCgpaFromSubjects(maxSem: maxSem);
  }

  void _recomputeCgpaFromSubjects({int? maxSem}) {
    double totalCredits = 0;
    double totalPoints = 0;

    for (final s in subjects) {
      if (s.semester <= 0) continue;    // ignore templates
      if (s.grade.isEmpty) continue;    // ignore not graded

      final gp = gradePoints[s.grade.toUpperCase()] ?? 0;
      totalCredits += s.credits;
      totalPoints += gp * s.credits;
    }

    if (totalCredits == 0) {
      cgpa.value = 0;
    } else {
      cgpa.value = totalPoints / totalCredits;
    }

    // Sync into CgpaController (for your CGPA main screen)
    if (Get.isRegistered<CgpaController>()) {
      final cgpaCtrl = Get.find<CgpaController>();

      final currentSem = maxSem ??
          (gpas.isEmpty
              ? 0
              : gpas
                  .map((g) => g.semester)
                  .reduce((a, b) => a > b ? a : b));

      if (cgpaCtrl.cgpaList.isEmpty) {
        cgpaCtrl.addCgpa(
          CgpaModel(cgpa: cgpa.value, currentSem: currentSem),
        );
      } else {
        cgpaCtrl.updateCgpa(
          0,
          CgpaModel(cgpa: cgpa.value, currentSem: currentSem),
        );
      }
    }
  }

  /// Used by "Calculate & Save CGPA" button – just recomputes everything
  Future<void> calculateAndSave() async {
    await recalculateAll();
  }

  Future<void> clearAllCgpaData() async {
    // 1️⃣ Delete all non-template subjects
    final toDelete = subjects.where((s) => s.semester > 0).toList();
    for (final s in toDelete) {
      await s.delete();
      subjects.remove(s);
    }

    // 2️⃣ Clear GPA records
    await gpaBox.clear();
    gpas.clear();

    // 3️⃣ Reset CGPA value
    cgpa.value = 0.0;

    // 4️⃣ Clear CGPA summary box
    if (Get.isRegistered<CgpaController>()) {
      final cgCtrl = Get.find<CgpaController>();
      await cgCtrl.clearAllCgpa();
    }

    // 🔥 5️⃣ CLEAR INTERNAL DATA
    if (Get.isRegistered<InternalCalcController>()) {
      final internalCtrl = Get.find<InternalCalcController>();
      await internalCtrl.clearAllInternalData();
    }
  }


  // ---------------------------------------------------------------------------
  // Helper for filtering by metaMapping (reg, dept, sem)
  // ---------------------------------------------------------------------------

  /// metaMapping format example: "21^25$CB^CS^AD$3^4^5"
  ///  - regs   = ["21", "25"]
  ///  - depts  = ["CB", "CS", "AD"]
  ///  - sems   = ["3", "4", "5"]
  bool subjectMatchesMeta(
    SubjectModel subject, {
    String? regulation,  // e.g. "2021" or "21"
    String? department,  // e.g. "CB"
    int? semester,       // e.g. 3
  }) {
    final mapping = subject.metaMapping;
    if (mapping.isEmpty) return false;

    final parts = mapping.split('\$');
    if (parts.length < 3) return false;

    final regs = parts[0].split('^');   // ["21","25"]
    final depts = parts[1].split('^');  // ["CB","CS","AD"]
    final sems = parts[2].split('^');   // ["3","4","5"]

    if (regulation != null) {
      final regKey =
          regulation.length == 4 ? regulation.substring(2) : regulation;
      if (!regs.contains(regKey)) return false;
    }

    if (department != null) {
      if (!depts.contains(department)) return false;
    }

    if (semester != null) {
      if (!sems.contains(semester.toString())) return false;
    }

    return true;
  }



  Future<void> removeSubjectAndCleanup(SubjectModel subject) async {
    // 1️⃣ Remove subject from Hive
    await subject.delete();
    subjects.remove(subject);

    // 2️⃣ Cleanup internal marks
    if (Get.isRegistered<InternalCalcController>()) {
      final internalCtrl = Get.find<InternalCalcController>();

      final marksToDelete = internalCtrl.markList
          .where((m) => m.subjectCode == subject.code)
          .toList();

      for (final m in marksToDelete) {
        await m.delete();
        internalCtrl.markList.remove(m);
      }

      // 3️⃣ Recalculate all internal GPAs affected
      final affectedPairs = marksToDelete
          .map((m) => '${m.semester}-${m.internalNo}')
          .toSet();

      for (final key in affectedPairs) {
        final parts = key.split('-');
        final sem = int.parse(parts[0]);
        final internalNo = int.parse(parts[1]);
        await internalCtrl.calculateInternalGpa(sem, internalNo);
      }
    }

    // 4️⃣ Recalculate CGPA
    await recalculateAll();
  }

  Map<String, List<SubjectModel>> groupByCategory(
    List<SubjectModel> list,
  ) {
    return {
      'core': list.where((s) => s.category == 'core').toList(),
      'pe': list.where((s) => s.category == 'pe').toList(),
      'oe': list.where((s) => s.category == 'oe').toList(),
    };
  }


}
