import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './Features/calculate_internal_screen.dart';
import './Features/virtualize_performance.dart';
import './Features/predict_cgpa.dart';
import '../controllers/cgpa_controller.dart';
import '../controllers/cgpa_calc_controller.dart';
import './calculate_cgpa_screen.dart';
import '../controllers/theme_controller.dart'; 
import '../controllers/ad_controller.dart';


class CGPAScreen extends StatelessWidget {
  // Use Get.put so controller is available if not created yet
  final CgpaController cgpaController = Get.put(CgpaController());
  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final AdController adController = Get.find<AdController>();
  
  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Obx(() {
          // ---------- GET DATA FROM HIVE VIA CONTROLLER ----------
          bool hasData = cgpaController.cgpaList.isNotEmpty;
          double cgpa = hasData ? cgpaController.cgpaList.last.cgpa : 0.0;
          int currentSem =
              hasData ? cgpaController.cgpaList.last.currentSem : 0;
          int percentage = (cgpa / 10 * 100).round();
          final gpaMap = calcController.gpaPerSem;


          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  "CGPA Calculator",
                  style: TextStyle(
                    fontSize: 22,
                    color: palette.minimal,
                    fontFamily: 'Righteous',
                  ),
                ),
                SizedBox(height: 25),
                

                // TOP CARD
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$percentage%",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 50,
                              color:palette.accent,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cgpa.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 35,
                              color:  palette.accent,
                            ),
                          ),
                          SizedBox(height: 0),
                          Text(
                            // previously: "CGPA Upto Sem ${"8"}",
                            "CGPA Upto Sem ${currentSem == 0 ? "-" : currentSem}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color:
                                  palette.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // FEATURE GRID
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        final sem1Gpa = gpaMap[1];
                        final sem2Gpa = gpaMap[2];
                        final sem3Gpa = gpaMap[3];
                        final sem4Gpa = gpaMap[4];
                        final sem5Gpa = gpaMap[5];

                        if(sem1Gpa != null && sem2Gpa != null && sem3Gpa !=null && sem4Gpa!=null && sem5Gpa!=null){
                          adController.showRewarded(() {
                            Get.to(() => CalculateInternalScreen());
                          });
                        }else if (sem1Gpa != null && sem2Gpa != null) {
                          adController.showInterstitial(() {
                            Get.to(() => CalculateInternalScreen());
                          });
                        }
                        else {
                          Get.to(() => CalculateInternalScreen());
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.functions,
                                color: palette.primary, size: 25),
                            SizedBox(height: 12),
                            Text(
                              "Internal Marks\nCalculation",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: palette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        final sem1Gpa = gpaMap[1];
                        final sem2Gpa = gpaMap[2];

                        if (sem1Gpa != null && sem2Gpa != null) {
                          adController.showRewarded(() {
                            Get.to(() => PredictCgpaPage());
                          });
                        }
                        else {
                          Get.to(() => PredictCgpaPage());
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: palette.primary, size: 25),
                            SizedBox(height: 12),
                            Text(
                              "Predict CGPA\nwith GPA",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: palette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        final sem1Gpa = gpaMap[1];
                        final sem2Gpa = gpaMap[2];

                        if (sem1Gpa != null && sem2Gpa != null) {
                          adController.showRewarded(() {
                            Get.to(() => VisualizePerformanceScreen());
                          });
                        }
                        else {
                          Get.to(() => VisualizePerformanceScreen());
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart,
                                color: palette.primary, size: 25),
                            SizedBox(height: 12),
                            Text(
                              "Virtualize\nPerformance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: palette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // GPA TABLE (still static UI here; you can later wire it to gpaBox)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: palette.black.withAlpha(100), // line color
                        width: 1, // line thickness
                      ),
                      // Remove all outer borders
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      verticalInside: BorderSide.none,
                    ),
                    children: [
                      TableRow(children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Semester",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: palette.minimal,
                            ),
                          ),
                        ),
                        SizedBox(),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "GPA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: palette.minimal,
                            ),
                          ),
                        ),
                      ]),

                      // Dynamic GPA rows for Sem 1 → 8
                      ...List.generate(8, (index) {
                        final sem = index + 1;
                        final gpa = gpaMap[sem];

                        return TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              sem.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: palette.primary,
                              ),
                            ),
                          ),
                          SizedBox(),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              gpa == null ? "--" : gpa.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: palette.primary,
                              ),
                            ),
                          ),
                        ]);
                      }),
                    ]

                  ),
                ),
                SizedBox(height: 40),

                // BOTTOM BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    final sem1Gpa = gpaMap[1];
                    final sem2Gpa = gpaMap[2];
                    final sem3Gpa = gpaMap[3];
                    final sem4Gpa = gpaMap[4];
                    final sem5Gpa = gpaMap[5];

                    if(sem1Gpa != null && sem2Gpa != null && sem3Gpa !=null && sem4Gpa!=null && sem5Gpa!=null){
                      adController.showRewarded(() {
                        Get.to(() => CalculateCgpaScreen());
                      });
                    }else if (sem1Gpa != null && sem2Gpa != null) {
                      adController.showInterstitial(() {
                        Get.to(() => CalculateCgpaScreen());
                      });
                    }
                    else {
                      Get.to(() => CalculateCgpaScreen());
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: 5),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate,
                            color: palette.accent, size: 25),
                        SizedBox(width: 10),
                        Text(
                          "Calculate CGPA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: palette.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
