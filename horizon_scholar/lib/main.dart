import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:horizon_scholar/controllers/internal_calc_controller.dart';
import 'package:horizon_scholar/models/internal_gpa_model.dart';
import 'package:horizon_scholar/models/internal_mark_model.dart';
import 'package:horizon_scholar/models/internal_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// MODELS

import 'models/cgpa_model.dart';
import 'models/document_model.dart';
import 'models/course_model.dart';
import 'models/subject_model.dart';
import 'models/gpa_model.dart';

import 'controllers/cgpa_calc_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/ad_controller.dart';

// =====

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await MobileAds.instance.initialize();
  Hive.registerAdapter(CgpaModelAdapter());
  Hive.registerAdapter(DocumentModelAdapter());
  Hive.registerAdapter(CourseModelAdapter());
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(GpaModelAdapter());
  Hive.registerAdapter(InternalGpaModelAdapter());
  Hive.registerAdapter(InternalMarkModelAdapter());
  Hive.registerAdapter(InternalModelAdapter());

  await Hive.openBox('app_meta');
  await Hive.openBox<CgpaModel>('cgpaBox');
  await Hive.openBox<DocumentModel>('documentsBoxV2');
  await Hive.openBox<CourseModel>('courseBox');
  await Hive.openBox<SubjectModel>('subjectBox');
  await Hive.openBox<GpaModel>('gpaBox');
  await Hive.openBox<InternalGpaModel>('internalGpaBox');
  await Hive.openBox<InternalMarkModel>('internalMarkBox');
  await Hive.openBox<InternalModel>('internalBox');

  final settingsBox = await Hive.openBox('settingsBox');
  
  Get.put(AdController(), permanent: true);
  Get.put(CgpaCalcController(), permanent: true);
  Get.put(InternalCalcController(), permanent: true);
  Get.put(ThemeController(settingsBox), permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Horizon Scholar',
          debugShowCheckedModeBanner: false,
          theme: themeController.themeData,

          // 🔥 IMPORTANT
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
        );
      },
    );
  }
}

