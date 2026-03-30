class Pet {
  final String name;
  final String breed;
  final String age;
  final String type;
  final String color;
  final String weight;
  final String? imagePath;

  bool isActiveQR;
  String ownerContact;
  String medicalInfo;

  Pet({
    required this.name,
    required this.breed,
    required this.age,
    required this.type,
    required this.color,
    required this.weight,
    this.imagePath,
    this.isActiveQR = true,
    this.ownerContact = "Not set",
    this.medicalInfo = "None",
  });
}
