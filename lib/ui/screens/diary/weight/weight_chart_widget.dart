import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/diary/weight/weight_chart_data.dart';

class WeightChartWidget extends StatelessWidget {
  const WeightChartWidget({Key? key}) : super(key: key);

  Future<WeightChartData> chartData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final res = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary')
        .orderBy('date', descending: true)
        .get();

    if (res.docs.isNotEmpty) {
      final filteredDocs = res.docs
          .where((doc) =>
              doc.data().containsKey('weight') &&
              doc.data().containsKey('date'))
          .take(7)
          .toList()
          .reversed
          .toList(); // reversed to make the earliest date first on chart

      final weights = filteredDocs
          .map((doc) => doc.get('weight') as List)
          .map((weightList) => weightList.last)
          .toList();

      final spots = List<FlSpot>.generate(
        weights.length,
        (index) => FlSpot(
          index.toDouble(),
          double.parse(weights[index]["weight"]),
        ),
      );

      final bottomTitles = filteredDocs.map((doc) {
        final date = doc.get('date').toDate(); // assuming Timestamp type
        return '${date.day}/${date.month}';
      }).toList();

      final allValues = weights.map((w) => double.parse(w["weight"])).toList();
      final minY = allValues.reduce((a, b) => a < b ? a : b) - 5;
      final maxY = allValues.reduce((a, b) => a > b ? a : b) + 5;

      return WeightChartData(
        spots: spots,
        bottomTitles: bottomTitles,
        minY: minY,
        maxY: maxY,
      );
    }

    return WeightChartData(
      spots: [],
      bottomTitles: [],
      minY: 50,
      maxY: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeightChartData>(
        future: chartData(),
        builder: (context, snapshot) {
          return LineChart(
            LineChartData(
              gridData: const FlGridData(
                  drawVerticalLine: false, drawHorizontalLine: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      var day = snapshot.data?.bottomTitles[value.toInt()];
                      if (day != null) {
                        return Text(day.toString());
                      }
                      return Container();
                    },
                    // getTitlesWidget: weightBottomTitleWidgets,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: weightLeftTitleWidgets,
                    reservedSize: 42,
                  ),
                ),
              ),
              minX: 0,
              maxX: (snapshot.data?.spots.length.toDouble() ?? 4.0) - 1,
              minY: snapshot.data?.minY,
              maxY: snapshot.data?.maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: snapshot.data?.spots ?? [],
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 92, 98, 255),
                      Color.fromARGB(255, 73, 79, 255),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    show: false,
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget weightLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    if (value % 5 == 0) {
      text = value.toInt().toString();
    } else {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
