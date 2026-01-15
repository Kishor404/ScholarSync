import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/cgpa_model.dart';

class CgpaController extends GetxController {
  /// Observable list of CGPA records
  var cgpaList = <CgpaModel>[].obs;

  late Box<CgpaModel> cgpaBox;

  @override
  void onInit() {
    super.onInit();
    cgpaBox = Hive.box<CgpaModel>('cgpaBox');
    loadCgpa();
  }

  /// Load all CGPA records from Hive into the observable list
  void loadCgpa() {
    cgpaList.value = cgpaBox.values.toList();
  }

  /// Add a new CGPA record (e.g. when calculating for the first time)
  void addCgpa(CgpaModel cgpa) {
    cgpaBox.add(cgpa);
    loadCgpa();
  }

  /// Update an existing CGPA record at index
  /// In our usage we almost always update index 0
  void updateCgpa(int index, CgpaModel newCgpa) {
    cgpaBox.putAt(index, newCgpa);
    loadCgpa();
  }

  /// Delete a CGPA record at index
  void deleteCgpa(int index) {
    cgpaBox.deleteAt(index);
    loadCgpa();
  }

  Future<void> clearAllCgpa() async {
    await cgpaBox.clear();
    cgpaList.clear();
  }

  /// Convenience: get the latest CGPA (or null if none)
  CgpaModel? get latestCgpa {
    if (cgpaList.isEmpty) return null;
    return cgpaList.last;
  }
}
