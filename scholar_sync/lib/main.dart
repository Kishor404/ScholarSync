import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './controllers/internal_calc_controller.dart';
import './models/internal_gpa_model.dart';
import './models/internal_mark_model.dart';
import './models/internal_model.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

// MODELS

import 'models/cgpa_model.dart';
import 'models/document_model.dart';
import 'models/course_model.dart';
import 'models/subject_model.dart';
import 'models/gpa_model.dart';

import 'controllers/cgpa_calc_controller.dart';
import 'controllers/user_pref_controller.dart';
import 'controllers/theme_controller.dart';
//import 'controllers/ad_controller.dart';

// =====

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  //await MobileAds.instance.initialize();
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
  
  //Get.put(AdController(), permanent: true);
  Get.put(CgpaCalcController(), permanent: true);
  Get.put(InternalCalcController(), permanent: true);
  Get.put(ThemeController(settingsBox), permanent: true);
  Get.put(UserPrefController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'ScholarSync',
          debugShowCheckedModeBanner: false,
          theme: themeController.themeData,

          builder: (context, child) {
            // 🔥 Get REAL device metrics (not OEM-scaled)
            final view = WidgetsBinding
                .instance.platformDispatcher.views.first;

            final baseMediaQuery = MediaQueryData.fromView(view);

            return MediaQuery(
              data: baseMediaQuery.copyWith(
                textScaler: const TextScaler.linear(1.0), // 🔒 lock font
                boldText: false, // 🔒 disable system bold text
              ),
              child: child!,
            );
          },

          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
        );
      },
    );
  }
}

