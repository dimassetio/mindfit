import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/diary/weight/weight_chart_widget.dart';
import 'package:health_tracker/ui/widgets/indicator_widget.dart';

class WeightDetailsScreen extends StatefulWidget {
  const WeightDetailsScreen({Key? key}) : super(key: key);

  @override
  State<WeightDetailsScreen> createState() => _WeightDetailsScreenState();
}

Future<Map<String, dynamic>?> getLatestWeight() async {
  var res = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('diary')
      .orderBy(FieldPath.fromString('date'), descending: true)
      .limit(1)
      .get();

  if (res.docs.isNotEmpty &&
      (res.docs.first as DocumentSnapshot<Map<String, dynamic>>)
          .data()!
          .containsKey('weight')) {
    return (res.docs.first.get('weight') as List).last;
  }
  return null;
}

class _WeightDetailsScreenState extends State<WeightDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(context),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  FutureBuilder(
                      future: getLatestWeight(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const MyCircularIndicator();
                        } else if (snapshot.hasData) {
                          String weight = snapshot.data['weight'];
                          return Text(
                            weight,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36),
                          );
                        } else {
                          return Text(
                            '0',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 36),
                          );
                        }
                      }),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'kg',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 139, 139, 139),
                        fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: WeightChartWidget()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: const Text(
        'Berat Badan',
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
