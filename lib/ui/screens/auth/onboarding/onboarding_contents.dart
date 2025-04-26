class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents(
      {required this.title, required this.image, required this.desc});
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Pantau Perkembanganmu",
    image: "assets/illustrations/Fitness tracker-amico_red.png",
    desc: "Ingat untuk selalu memantau pencapaian perjalanan kebugaranmu.",
  ),
  OnboardingContents(
    title: "Bergabunglah dengan Komunitas Kami!",
    image: "assets/illustrations/Coaches-amico_red.png",
    desc:
        "Terhubung dan berbagi pengetahuan dengan pecinta kebugaran dari seluruh dunia!",
  ),
  OnboardingContents(
    title: "Tindakan adalah Kunci Segala Kesuksesan",
    image: "assets/illustrations/Timeline-amico_red.png",
    desc:
        "Kami siap membantumu mencapai tujuan kebugaran lewat tantangan, rencana, dan resep sehat kami!",
  ),
];
