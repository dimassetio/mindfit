import 'package:fl_chart/fl_chart.dart';

class WeightChartData {
  final List<FlSpot> spots;
  final List<String> bottomTitles;
  final double minY;
  final double maxY;

  WeightChartData({
    required this.spots,
    required this.bottomTitles,
    required this.minY,
    required this.maxY,
  });
}
