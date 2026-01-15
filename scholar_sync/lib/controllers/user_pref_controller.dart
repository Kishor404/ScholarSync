import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefController extends GetxController {
  final selectedReg = RxnString();
  final selectedDept = RxnString();

  static const _regKey = 'selected_regulation';
  static const _deptKey = 'selected_department';

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    selectedReg.value = prefs.getString(_regKey);
    selectedDept.value = prefs.getString(_deptKey);
  }

  Future<void> setReg(String? reg) async {
    selectedReg.value = reg;
    final prefs = await SharedPreferences.getInstance();
    if (reg == null) {
      prefs.remove(_regKey);
    } else {
      prefs.setString(_regKey, reg);
    }
  }

  Future<void> setDept(String? dept) async {
    selectedDept.value = dept;
    final prefs = await SharedPreferences.getInstance();
    if (dept == null) {
      prefs.remove(_deptKey);
    } else {
      prefs.setString(_deptKey, dept);
    }
  }
}
