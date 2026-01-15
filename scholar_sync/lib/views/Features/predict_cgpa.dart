import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
//import 'package:horizon_scholar/widgets/banner_ad_widget.dart';
import '../../models/gpa_model.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';


class PredictCgpaPage extends StatefulWidget {
  const PredictCgpaPage({super.key});

  @override
  State<PredictCgpaPage> createState() => _PredictCgpaPageState();
}

class _PredictCgpaPageState extends State<PredictCgpaPage> {

  final ThemeController themeController = Get.find<ThemeController>();
  
  double? predictedGpa;
  String? error;
  List<GpaModel> semesterData = [];

  @override
  void initState() {
    super.initState();
    _predict();
  }

  Future<void> _predict() async {
    try {
      final box = Hive.box<GpaModel>('gpaBox');
      final data = box.values.toList();

      if (data.length < 2) {
        setState(() {
          error = "Add at least 2 semesters to predict CGPA";
        });
        return;
      }

      if (data.length > 7) {
        setState(() {
          error = "No More Futher Semester";
        });
        return;
      }

      data.sort((a, b) => a.semester.compareTo(b.semester));

      final prediction = GpaRegression.predictNextSemester(data);

      setState(() {
        semesterData = data; // 👈 only store for UI
        predictedGpa = double.parse(prediction.toStringAsFixed(2));
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    final w = MediaQuery.of(context).size.width;
    final s=w/460;
    return Scaffold(
      appBar: AppBar(
        title:Text("Predict Next Semester CGPA", style: TextStyle(
          fontSize: 20*s,
          fontFamily: 'Righteous',
          color: palette.accent,
        ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: palette.primary,
        foregroundColor: palette.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20*s),
        child: Center(
          child: error != null
              ? Text(
                  error!,
                  style: TextStyle(color: palette.error),
                )
              : predictedGpa == null
                  ? const CircularProgressIndicator()
                  : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFF5ACD),
                    Color(0xFFB44CFF),
                    Color(0xFF6A5CFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(
                  Icons.auto_awesome,
                  size: 64*s,
                  color: palette.accent,
                ),
              ),



              SizedBox(height: 16*s),

              

              Text(
                predictedGpa!.toString(),
                style: TextStyle(
                  fontSize: 48*s,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 179),
                        Color(0xFFB44CFF),
                        Color(0xFF6A5CFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                      const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                    ),
                ),
              ),

              const SizedBox(height: 6),

              /// --------------------
              /// Prediction
              /// --------------------
              Text(
                "Predicted GPA for ${semesterData.last.semester + 1} Semester",
                style: TextStyle(
                  fontSize: 16*s,
                  fontWeight: FontWeight.w500,
                  color: palette.black.withAlpha(150),
                ),
              ),

              SizedBox(height: 20*s),
              
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12*s),
                ),
                color: palette.primary,
                elevation: 0,
                
                child: Padding(
                  padding: EdgeInsets.all(18*s),
                  child: Column(
                    children: semesterData.map((item) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4*s),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Semester ${item.semester}",
                              style: TextStyle(
                                color: palette.accent,
                                fontWeight: FontWeight.w500,
                                fontSize: 14*s
                              ),
                            ),
                            Text(
                              item.gpa.toStringAsFixed(2),
                              style: TextStyle(
                                color: palette.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 14*s
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              //BannerAdWidget(),
            ],
          )

        ),
      ),
    );
  }
}


class GpaRegression {
  static double predictNextSemester(List<GpaModel> data) {
    if (data.length < 2) {
      throw Exception("At least 2 semesters required for prediction");
    }
    if(data.length > 7){
      throw Exception("No More Further Semester !");
    }

    final n = data.length;

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (final item in data) {
      final x = item.semester.toDouble();
      final y = item.gpa;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final m = ((n * sumXY) - (sumX * sumY)) /
        ((n * sumX2) - (sumX * sumX));

    final c = (sumY - m * sumX) / n;

    final nextSemester = data.last.semester + 1;
    final predictedGpa = (m * nextSemester) + c;

    return predictedGpa.clamp(0.0, 10.0);
  }
}
