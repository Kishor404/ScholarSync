import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GpaPieChart extends StatelessWidget {
  final Map<int, double> gpaPerSem;

  const GpaPieChart({
    super.key,
    required this.gpaPerSem,
  });

  @override
  Widget build(BuildContext context) {
    final total = gpaPerSem.values.fold(0.0, (a, b) => a + b);

    return AspectRatio(
      aspectRatio: 1.2,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: gpaPerSem.entries.map((e) {
            final percent = (e.value / total) * 100;

            return PieChartSectionData(
              value: e.value,
              title: "S${e.key}\n${percent.toStringAsFixed(1)}%",
              titleStyle: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              radius: 55,
              color: Colors.primaries[e.key % Colors.primaries.length],
            );
          }).toList(),
        ),
      ),
    );
  }
}
