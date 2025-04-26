import 'package:health_tracker/data/models/onboarding_model.dart';
import 'package:health_tracker/shared/constants/assets_path.dart';

enum Sex { male, female }

List<OnBoardingModel> onboardinglist = const [
  OnBoardingModel(
    img: MyAssets.onboradingone,
    title: 'Kelola Tugasmu',
    description:
        'Dengan aplikasi kecil ini, kamu bisa mengatur semua tugas dan kewajibanmu dalam satu aplikasi.',
  ),
  OnBoardingModel(
    img: MyAssets.onboradingtwo,
    title: 'Rencanakan Harimu',
    description: 'Tambahkan tugas dan aplikasi akan mengingatkannya untukmu.',
  ),
  OnBoardingModel(
    img: MyAssets.onboradingthree,
    title: 'Capai Tujuanmu',
    description: 'Lacak aktivitasmu dan capai semua tujuanmu.',
  ),
];
