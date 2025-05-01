import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Notifikasi'),
        ),
        body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: TabBar(
                    tabs: const [
                      Text('Notifikasi'),
                      Text('Pesan'),
                    ],
                    // indicatorColor: Colors.red,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(colors: [
                          Color.fromARGB(255, 255, 88, 128),
                          Color.fromARGB(255, 250, 124, 108),
                        ])),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
                const Expanded(
                    child: TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Hari ini',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text('Tidak ada yang ditampilkan hari ini...'),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Minggu ini',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text('Tidak ada yang ditampilkan minggu ini...'),
                        ],
                      ),
                    ),
                    Text('Pesan'),
                  ],
                ))
              ],
            )));
  }
}
