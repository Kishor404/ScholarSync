import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:horizon_scholar/widgets/banner_ad_widget.dart';
import '../../widgets/semester_gpa_bar_chart.dart';
import '../../widgets/gpa_pie_chart.dart';
import '../../controllers/cgpa_calc_controller.dart';
import '../../controllers/theme_controller.dart';

class VisualizePerformanceScreen extends StatelessWidget {
  const VisualizePerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CgpaCalcController cgpaCtrl =
        Get.find<CgpaCalcController>();
    
    final ThemeController themeController = Get.find<ThemeController>();

    final palette = themeController.palette;
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.black),
        title: Text(
          "Visualize Performance",
          style: TextStyle(
            fontSize: 22*s,
            fontFamily: 'Righteous',
            color: palette.black,
          ),
        ),
      ),
      body: SafeArea(
        child:Obx(() {
          final cgpa = cgpaCtrl.cgpa.value;
          final gpaMap = cgpaCtrl.gpaPerSem;

          if (gpaMap.isEmpty) {
            return Center(
              child: Text(
                "No GPA data available yet",
                style: TextStyle(fontSize: 14*s),
              ),
            );
          }

          final sorted = gpaMap.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          final best = sorted.reduce(
            (a, b) => a.value > b.value ? a : b,
          );

          final lowest = sorted.reduce(
            (a, b) => a.value < b.value ? a : b,
          );

          final improving = sorted.length >= 2 &&
              sorted.last.value > sorted[sorted.length - 2].value;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                // ---------------- CGPA CARD ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(18*s),
                  ),
                  child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cgpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 35*s,
                                color:  palette.accent,
                              ),
                            ),
                            SizedBox(height: 0),
                            Text(
                              // previously: "CGPA Upto Sem ${"8"}",
                              "Current CGPA",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14*s,
                                color:
                                    palette.accent,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.bar_chart_outlined,
                              size: 50*s,
                              color: palette.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                ),

                SizedBox(height: 20*s),
                //BannerAdWidget(),
                SizedBox(height: 20*s),

                // ---------------- PIE CHART ----------------
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16*s),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(16*s),
                  ),
                  child: Column(

                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "GPA Distribution",
                          style: TextStyle(
                            fontSize: 15*s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10*s),
                      GpaPieChart(gpaPerSem: gpaMap),
                    ],
                  )
                ),
                

                SizedBox(height: 16*s),

                

                // ---------------- INSIGHTS ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(16*s),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Performance Insights",
                        style: TextStyle(
                          fontSize: 15*s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8*s),
                      Text(
                        improving
                            ? "📈 Your performance is improving."
                            : "⚠️ Your performance needs attention.",
                        style: TextStyle(fontSize: 13*s),
                      ),
                      SizedBox(height: 4*s),
                      Text(
                        "🔥 Best Semester: Sem ${best.key} (GPA ${best.value.toStringAsFixed(2)})",
                        style: TextStyle(fontSize: 13*s),
                      ),
                      SizedBox(height: 4*s),
                      Text(
                        "❄️ Lowest Semester: Sem ${lowest.key} (GPA ${lowest.value.toStringAsFixed(2)})",
                        style: TextStyle(fontSize: 13*s),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22*s),

                // ---------------- BAR CHART ----------------

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16*s),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(16*s),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Semester GPA Trend",
                          style: TextStyle(
                            fontSize: 15*s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10*s),
                      SemesterGpaBarChart(gpaPerSem: gpaMap),
                    ],
                  ),
                ),
                

                SizedBox(height: 24*s),

                // ---------------- GPA LIST ----------------

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16*s),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(16*s),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Semester-wise GPA",
                          style: TextStyle(
                            fontSize: 15*s,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 8*s),

                      ...sorted.map(
                        (e) => Container(
                          margin: EdgeInsets.only(bottom: 10*s),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14*s,
                            vertical: 12*s,
                          ),
                          decoration: BoxDecoration(
                            color: palette.primary,
                            borderRadius: BorderRadius.circular(14*s),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                color: palette.black.withAlpha(10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Semester ${e.key}",
                                style: TextStyle(
                                  fontSize: 14*s,
                                  color: palette.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                e.value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 16*s,
                                  fontWeight: FontWeight.w700,
                                  color: palette.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ],
            ),
          );
        }),
      )
    );
  }
}
