import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './Features/calculate_internal_screen.dart';
import './Features/virtualize_performance.dart';
import './Features/predict_cgpa.dart';
import '../controllers/cgpa_controller.dart';
import '../controllers/cgpa_calc_controller.dart';
import './calculate_cgpa_screen.dart';
import '../controllers/theme_controller.dart'; 
//import '../controllers/ad_controller.dart';


class CGPAScreen extends StatelessWidget {
  CGPAScreen({super.key});
  // Use Get.put so controller is available if not created yet
  final CgpaController cgpaController = Get.put(CgpaController());
  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();
  //final AdController adController = Get.find<AdController>();
  
  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
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
            padding: EdgeInsets.all(20*s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  "CGPA Calculator",
                  style: TextStyle(
                    fontSize: 22*s,
                    color: palette.minimal,
                    fontFamily: 'Righteous',
                  ),
                ),
                SizedBox(height: 25*s),
                

                // TOP CARD
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 40*s, horizontal: 30*s),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(15*s),
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
                              fontSize: 45*s,
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
                              fontSize: 30*s,
                              color:  palette.accent,
                            ),
                          ),
                          SizedBox(height: 5*s),
                          Text(
                            // previously: "CGPA Upto Sem ${"8"}",
                            "CGPA Upto Sem ${currentSem == 0 ? "-" : currentSem}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14*s,
                              color:
                                  palette.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25*s),

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
                          borderRadius: BorderRadius.circular(15*s),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Get.to(() => CalculateInternalScreen());
                        // final sem1Gpa = gpaMap[1];
                        // final sem2Gpa = gpaMap[2];
                        // final sem3Gpa = gpaMap[3];
                        // final sem4Gpa = gpaMap[4];
                        // final sem5Gpa = gpaMap[5];

                        // if(sem1Gpa != null && sem2Gpa != null && sem3Gpa !=null && sem4Gpa!=null && sem5Gpa!=null){
                        //   adController.showRewarded(() {
                        //     Get.to(() => CalculateInternalScreen());
                        //   });
                        // }else if (sem1Gpa != null && sem2Gpa != null) {
                        //   adController.showInterstitial(() {
                        //     Get.to(() => CalculateInternalScreen());
                        //   });
                        // }
                        // else {
                        //   Get.to(() => CalculateInternalScreen());
                        // }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5*s),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15*s),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.functions,
                                color: palette.primary, size: 25*s),
                            SizedBox(height: 12*s),
                            Text(
                              "Internal Marks\nCalculation",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12*s,
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
                        Get.to(() => PredictCgpaPage());
                        // final sem1Gpa = gpaMap[1];
                        // final sem2Gpa = gpaMap[2];

                        // if (sem1Gpa != null && sem2Gpa != null) {
                        //   adController.showRewarded(() {
                        //     Get.to(() => PredictCgpaPage());
                        //   });
                        // }
                        // else {
                        //   Get.to(() => PredictCgpaPage());
                        // }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5*s),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15*s),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: palette.primary, size: 25*s),
                            SizedBox(height: 12*s),
                            Text(
                              "Predict CGPA\nwith GPA",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12*s,
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
                        Get.to(() => VisualizePerformanceScreen());
                        // final sem1Gpa = gpaMap[1];
                        // final sem2Gpa = gpaMap[2];

                        // if (sem1Gpa != null && sem2Gpa != null) {
                        //   adController.showRewarded(() {
                        //     Get.to(() => VisualizePerformanceScreen());
                        //   });
                        // }
                        // else {
                        //   Get.to(() => VisualizePerformanceScreen());
                        // }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5*s),
                        decoration: BoxDecoration(
                          color: palette.secondary,
                          borderRadius: BorderRadius.circular(15*s),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart,
                                color: palette.primary, size: 25*s),
                            SizedBox(height: 12*s),
                            Text(
                              "Virtualize\nPerformance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12*s,
                                color: palette.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40*s),

                // GPA TABLE (still static UI here; you can later wire it to gpaBox)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20*s),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: palette.black.withAlpha(100), // line color
                        width: 1*s, // line thickness
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
                          padding: EdgeInsets.all(8*s),
                          child: Text(
                            "Semester",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16*s,
                              color: palette.minimal,
                            ),
                          ),
                        ),
                        SizedBox(),
                        Padding(
                          padding: EdgeInsets.all(8*s),
                          child: Text(
                            "GPA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16*s,
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
                            padding: EdgeInsets.all(8*s),
                            child: Text(
                              sem.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14*s,
                                color: palette.primary,
                              ),
                            ),
                          ),
                          SizedBox(),
                          Padding(
                            padding: EdgeInsets.all(8*s),
                            child: Text(
                              gpa == null ? "--" : gpa.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14*s,
                                color: palette.primary,
                              ),
                            ),
                          ),
                        ]);
                      }),
                    ]

                  ),
                ),
                SizedBox(height: 40*s),

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
                    Get.to(() => CalculateCgpaScreen());
                    // final sem1Gpa = gpaMap[1];
                    // final sem2Gpa = gpaMap[2];
                    // final sem3Gpa = gpaMap[3];
                    // final sem4Gpa = gpaMap[4];
                    // final sem5Gpa = gpaMap[5];

                    // if(sem1Gpa != null && sem2Gpa != null && sem3Gpa !=null && sem4Gpa!=null && sem5Gpa!=null){
                    //   adController.showRewarded(() {
                    //     Get.to(() => CalculateCgpaScreen());
                    //   });
                    // }else if (sem1Gpa != null && sem2Gpa != null) {
                    //   adController.showInterstitial(() {
                    //     Get.to(() => CalculateCgpaScreen());
                    //   });
                    // }
                    // else {
                    //   Get.to(() => CalculateCgpaScreen());
                    // }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 20*s, horizontal: 5*s),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(15*s),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate,
                            color: palette.accent, size: 25*s),
                        SizedBox(width: 10*s),
                        Text(
                          "Calculate CGPA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18*s,
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
