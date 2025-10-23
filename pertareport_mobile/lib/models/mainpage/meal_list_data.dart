// Model Data dengan warna Pertamina
class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/images/truck.png',
      titleTxt: 'Daily Report',
      kacl: 0,
      meals: <String>[],
      startColor: '#0E4A6B', // Pertamina Blue
      endColor: '#1565C0',   // Light Blue
    ),
    MealsListData(
      imagePath: 'assets/images/pegawai_5.png',
      titleTxt: 'Report Review',
      kacl: 0, 
      meals: <String>[],
      startColor: '#1B5E20', // Pertamina Green
      endColor: '#2E7D32',   // Darker Green
    ),
    MealsListData(
      imagePath: 'assets/images/pegawai_3.png',
      titleTxt: 'Tracking work',
      kacl: 0, 
      meals: <String>[],
      startColor: '#0E4A6B', // Pertamina Blue
      endColor: '#0D47A1',   // Deep Blue
    ),
    MealsListData(
      imagePath: 'assets/images/pegawai_4.png',
      titleTxt: 'Report Filtering & Sorting',
      kacl: 0,
      meals: <String>[],
      startColor: '#1B5E20', // Pertamina Green
      endColor: '#1B5E20',   // Same green for solid look
    ),
  ];
}