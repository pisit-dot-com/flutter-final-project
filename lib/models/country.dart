// ข้อมูลประเทศ 1 ประเทศ ที่ได้มาจาก API
class Country {
  final String code;    // รหัสประเทศ 2 ตัวอักษร เช่น "th"
  final String name;    // ชื่อประเทศ เช่น "Thailand"

  Country({required this.code, required this.name});

  // ลิงก์รูปธง สร้างจากรหัสประเทศ
  // เช่น th → https://flagcdn.com/w320/th.png
  String get flagUrl => 'https://flagcdn.com/w320/$code.png';
}