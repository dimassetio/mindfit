// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/ui/widgets/indicator_widget.dart';
import 'package:intl/intl.dart';

class WaterStatsScreen extends StatefulWidget {
  const WaterStatsScreen({Key? key}) : super(key: key);

  @override
  State<WaterStatsScreen> createState() => _HeartDetailsScreenState();
}

class _HeartDetailsScreenState extends State<WaterStatsScreen> {
  Future<int> getTodayWater() async {
    int water = 0;
    var res = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('diary')
        .doc(DateFormat('d-M-y').format(DateTime.now()))
        .get();
    if (res.exists && res.data()!.containsKey('water')) {
      return res.get('water');
    }
    return water;
  }

  Future<List<BarChartGroupData>> generateBarChartData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final diaryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary');

    List<String> last7DaysIds = [];
    DateTime now = DateTime.now();

    // Generate last 7 days' date IDs, oldest first
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('d-M-y').format(date);
      last7DaysIds.add(formattedDate);
    }

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < last7DaysIds.length; i++) {
      String docId = last7DaysIds[i];
      DocumentSnapshot doc = await diaryCollection.doc(docId).get();

      double waterValue = 0;
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        waterValue = (data['water'] ?? 0).toDouble();
      }

      barGroups.add(
        BarChartGroupData(
          x: i + 1, // x starts from 1 to 7
          barsSpace: 10,
          barRods: [
            BarChartRodData(
              width: 12,
              toY: waterValue,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade200,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  Future<double> getWeeklyAverageWater() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final diaryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary');

    DateTime now = DateTime.now();
    double totalWater = 0;
    int daysWithData = 0;

    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('d-M-y').format(date);

      DocumentSnapshot doc = await diaryCollection.doc(formattedDate).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['water'] != null) {
          double waterValue = (data['water'] ?? 0).toDouble();
          totalWater += waterValue;
          daysWithData++;
        }
      }
    }

    if (daysWithData == 0) {
      return 0; // Belum ada data sama sekali
    }

    double averageWater = totalWater / daysWithData;
    return averageWater;
  }

  Future<List<BarChartGroupData>> generateMonthlyBarChartData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final diaryCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary');

    DateTime now =
        DateTime.now(); // 29 hari ke belakang + hari ini (30 hari total)

    QuerySnapshot snapshot = await diaryCollection
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(now.year, now.month, 1)))
        .where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(
                DateTime(now.year, now.month, now.day, 23, 59, 59)))
        .orderBy('date')
        .get();

    Map<String, double> waterDataByDate = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['date'] != null) {
        DateTime date = (data['date'] as Timestamp).toDate();
        String formattedDate = DateFormat('d-M-y').format(date);
        waterDataByDate[formattedDate] = (data['water'] ?? 0).toDouble();
      }
    }

    List<BarChartGroupData> barGroups = [];

    // Generate last 30 days' labels
    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('d-M-y').format(date);
      double waterValue = waterDataByDate[formattedDate] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: 30 - i, // x = 1 to 30
          barsSpace: 4, // lebih kecil jaraknya karena 30 bar
          barRods: [
            BarChartRodData(
              width: 8, // lebih ramping karena banyak
              toY: waterValue,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade200,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(children: [
          SizedBox(
            height: 36,
            child: TabBar(
              isScrollable: true,
              tabs: const [
                Tab(
                  text: 'Minggu',
                ),
                Tab(
                  text: 'Bulan',
                ),
                Tab(
                  text: 'Tahun',
                ),
              ],
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [
                    Color.fromARGB(255, 255, 88, 128),
                    Color.fromARGB(255, 250, 124, 108),
                  ])),
              // indicatorColor: Colors.red,
              labelPadding: const EdgeInsets.symmetric(horizontal: 40),
            ),
          ),
          Expanded(
              child: TabBarView(children: [
            WaterChart(
                todayWater: getTodayWater(),
                chartData: generateBarChartData(),
                averageWater: getWeeklyAverageWater()),
            WaterChart(
                todayWater: getTodayWater(),
                chartData: generateMonthlyBarChartData(),
                averageWater: getWeeklyAverageWater()),
            WaterChart(
                todayWater: getTodayWater(),
                chartData: generateMonthlyBarChartData(),
                averageWater: getWeeklyAverageWater()),
          ]))
        ]),
      ),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: const Text(
        'Air',
        style: TextStyle(fontSize: 20),
      ),
      leading: TextButton(
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.chevron_left,
            size: 34,
          )),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
              shape: const CircleBorder(),
            ),
            onPressed: () {},
            child: const Icon(
              Icons.settings,
              size: 28,
            )),
        // const SizedBox(
        //   width: 14,
        // ),
      ],
    );
  }
}

Widget bottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color.fromARGB(255, 191, 191, 191),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // List nama hari dalam Bahasa Indonesia (urutan: Minggu -> Sabtu)
  const daysInIndonesian = [
    'Min', // Sunday
    'Sen', // Monday
    'Sel', // Tuesday
    'Rab', // Wednesday
    'Kam', // Thursday
    'Jum', // Friday
    'Sab', // Saturday
  ];

  DateTime now = DateTime.now();

  // Hitung list 7 hari terakhir
  List<String> last7Days = [];

  for (int i = 6; i >= 0; i--) {
    DateTime date = now.subtract(Duration(days: i));
    int weekdayIndex =
        date.weekday % 7; // Karena DateTime.weekday: Monday = 1, Sunday = 7
    last7Days.add(daysInIndonesian[weekdayIndex]);
  }

  // value dari 1..7, index array dari 0..6
  int index = value.toInt() - 1;

  if (index < 0 || index >= last7Days.length) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      last7Days[index],
      style: style,
    ),
  );
}

Widget leftTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color.fromARGB(255, 191, 191, 191),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;
  switch (value.toInt()) {
    case 0:
      text = '0';
      break;
    case 1000:
      text = '1';
      break;
    case 2000:
      text = '2';
      break;
    case 3000:
      text = '3';
      break;
    case 4000:
      text = '4';
      break;
    default:
      return Container();
  }

  return Text(text, style: style, textAlign: TextAlign.left);
}

Widget WaterChart({
  required Future<int> todayWater,
  required Future<List<BarChartGroupData>> chartData,
  required Future<double> averageWater,
}) {
  int mlToGlass(double ml) {
    return (ml / 250.0).round();
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        Row(
          children: [
            FutureBuilder<int>(
                future: todayWater,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  if (!snapshot.hasData) {
                    return const MyCircularIndicator();
                  } else {
                    int water = snapshot.data ?? 0;
                    return Text(
                      water.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 36),
                    );
                  }
                }),
            const SizedBox(
              width: 8,
            ),
            const Text(
              'ml',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 139, 139, 139),
                  fontSize: 18),
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        SizedBox(
            height: 180,
            width: double.infinity,
            child: FutureBuilder<List<BarChartGroupData>>(
                future: chartData,
                builder: (context, snapshot) {
                  return BarChart(
                    BarChartData(
                        borderData: FlBorderData(show: false),
                        barGroups: snapshot.data ?? [],
                        maxY: 4000,
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  getTitlesWidget: leftTitles,
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 1)),
                          bottomTitles: (snapshot.data?.length ?? 0) <= 7
                              ? AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: bottomTitles,
                                    reservedSize: 42,
                                  ),
                                )
                              : AxisTitles(sideTitles: SideTitles()),
                          rightTitles: AxisTitles(),
                          topTitles: AxisTitles(),
                        )),
                  );
                })),
        const SizedBox(
          height: 24,
        ),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<double>(
                  future: averageWater,
                  builder: (context, snapshot) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    'Asupan Rata-rata',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      FontAwesomeIcons.glassWater,
                                      color: Colors.blue,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${snapshot.data?.toInt() ?? 0}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'ml/hari',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${mlToGlass(snapshot.data ?? 0)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'gelas/hari',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
      ],
    ),
  );
}
