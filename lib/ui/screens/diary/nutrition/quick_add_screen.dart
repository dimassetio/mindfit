import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health_tracker/data/repositories/firestore.dart';

class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({Key? key, required this.type}) : super(key: key);
  final String type;
  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  late TextEditingController foodNameController;
  late TextEditingController caloriesController;
  late TextEditingController proteinController;
  late TextEditingController carbsController;
  late TextEditingController fatController;

  String type = '';
  @override
  void initState() {
    super.initState();
    foodNameController = TextEditingController();
    caloriesController = TextEditingController();
    proteinController = TextEditingController();
    carbsController = TextEditingController();
    fatController = TextEditingController();
    type = widget.type;
  }

  @override
  void dispose() {
    foodNameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  String generateRandomUID({int length = 8}) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  String getRealType(String type) {
    switch (type) {
      case 'Sarapan':
        return 'Breakfast';
      case 'Makan Siang':
        return 'Lunch';
      case 'Makan Malam':
        return 'Dinner';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambahkan $type'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                FireStoreCrud().updateDiaryMeal(
                    getRealType(type),
                    generateRandomUID(),
                    'Quick Add',
                    foodNameController.text,
                    caloriesController.text == ''
                        ? 0
                        : double.parse(caloriesController.text),
                    proteinController.text == ''
                        ? 0
                        : double.parse(proteinController.text),
                    fatController.text == ''
                        ? 0
                        : double.parse(fatController.text),
                    carbsController.text == ''
                        ? 0
                        : double.parse(carbsController.text));
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(flex: 1, child: Text('Nama Makanan')),
                Expanded(
                    child: SizedBox(
                        child: TextField(
                  controller: foodNameController,
                  keyboardType: TextInputType.text,
                ))),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(flex: 5, child: Text('Kalori')),
                Expanded(
                    child: SizedBox(
                        child: TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                ))),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(flex: 5, child: Text('Protein')),
                Expanded(
                    child: SizedBox(
                        child: TextField(
                  controller: proteinController,
                  keyboardType: TextInputType.number,
                ))),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(flex: 5, child: Text('Karbohidrat')),
                Expanded(
                    child: SizedBox(
                        child: TextField(
                  controller: carbsController,
                  keyboardType: TextInputType.number,
                ))),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(flex: 5, child: Text('Lemak')),
                Expanded(
                    child: SizedBox(
                        child: TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                ))),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
