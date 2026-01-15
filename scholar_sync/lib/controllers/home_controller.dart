import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HomeController extends GetxController {
  static const _boxName = 'app_meta';
  static const _key = 'home_load_count';

  final loadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCount();
    _incrementLoad();
    //print('================== Home Screen Load Count: ${loadCount.value}');
  }

  void _loadCount() {
    final box = Hive.box(_boxName);
    loadCount.value = box.get(_key, defaultValue: 0);
  }

  void _incrementLoad() {
    final box = Hive.box(_boxName);
    final newCount = loadCount.value + 1;
    loadCount.value = newCount;
    box.put(_key, newCount);
  }

  /// ✅ SHOW banner only AFTER 5 loads
  bool get shouldShowBanner => loadCount.value > 5;
}
