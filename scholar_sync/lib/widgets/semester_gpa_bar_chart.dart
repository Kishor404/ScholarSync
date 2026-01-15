import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../controllers/theme_controller.dart';
import 'package:get/get.dart';


class SemesterGpaBarChart extends StatelessWidget {
  final Map<int, double> gpaPerSem;
  final ThemeController themeController = Get.find<ThemeController>();

  SemesterGpaBarChart({
    super.key,
    required this.gpaPerSem,
  });

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    final entries = gpaPerSem.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return AspectRatio(
      aspectRatio: 1.6,
      child: BarChart(
        BarChartData(
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(
                    "S${value.toInt()}",
                    style: TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 16,
                  borderRadius: BorderRadius.circular(2),
                  color: palette.primary,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
