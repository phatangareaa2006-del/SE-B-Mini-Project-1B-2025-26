import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BpLineChart extends StatelessWidget {
  final List<double> systolicData;
  final List<double> diastolicData;

  const BpLineChart({
    super.key,
    required this.systolicData,
    required this.diastolicData,
  });

  @override
  Widget build(BuildContext context) {
    if (systolicData.isEmpty || diastolicData.isEmpty) {
      return const Center(child: Text("Waiting for BP data...", style: TextStyle(color: Colors.white70)));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: systolicData.length.toDouble() - 1,
        minY: 40,
        maxY: 180,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(systolicData.length, (index) => FlSpot(index.toDouble(), systolicData[index])),
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.blueAccent)),
            belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.2)),
          ),
          LineChartBarData(
            spots: List.generate(diastolicData.length, (index) => FlSpot(index.toDouble(), diastolicData[index])),
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.teal)),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }
}
