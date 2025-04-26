import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/auth/about/widgets/gender_picker_widget.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:numberpicker/numberpicker.dart';

class AboutContents {
  final String title;
  final String desc;
  final Widget body;
  // dynamic value;

  AboutContents({required this.title, required this.body, required this.desc});
}

List<AboutContents> contents = [
  AboutContents(
      title: "Ceritakan Dirimu!",
      desc:
          "Untuk memberikan pengalaman lebih baik\n Kami butuh informasi jenis kelamin Anda",
      body: const GenderPicker()),
  AboutContents(
    title: "Berapa usia mu?",
    desc: "Ini membantu menyesuaikan kebutuhan Anda",
    body: NumberPicker(
      selectedTextStyle: const TextStyle(
          color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
      minValue: 0,
      maxValue: 140,
      value: 18,
      onChanged: (newValue) {},
    ),
  ),
  AboutContents(
    title: "Berapa berat badan Anda?",
    desc: "Anda dapat mengubah ini setiap saat",
    body: HorizontalPicker(
      initialPosition: InitialPosition.start,
      minValue: 0,
      maxValue: 500,
      divisions: 1000,
      height: 150,
      onChanged: (newValue) {},
      suffix: 'kg',
      activeItemTextColor: Colors.red,
    ),
  ),
];
