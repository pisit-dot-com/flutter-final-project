import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

// เรียก API ภายนอก: flagcdn.com
// ได้รายชื่อประเทศทั้งหมด พร้อมรหัสประเทศ (ใช้สร้างลิงก์รูปธง)
class CountryService {
  static const String apiUrl = 'https://flagcdn.com/en/codes.json';

  Future<List<Country>> fetchCountries() async {
    // 1. ส่งคำขอไปที่ API (รอไม่เกิน 10 วินาที)
    final response = await http
        .get(Uri.parse(apiUrl))
        .timeout(const Duration(seconds: 10));

    // 2. เช็คว่าสำเร็จไหม (200 = สำเร็จ)
    if (response.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${response.statusCode})');
    }

    // 3. แปลง JSON เป็น Map
    // ข้อมูลหน้าตาแบบนี้: {"th": "Thailand", "jp": "Japan", "us-ca": "California", ...}
    final Map<String, dynamic> data = jsonDecode(response.body);

    // 4. แปลงเป็น List ของ Country
    final countries = <Country>[];
    data.forEach((code, name) {
      // เอาเฉพาะรหัส 2 ตัวอักษร (ประเทศ)
      // ตัดพวกรัฐของอเมริกา เช่น "us-ca" ออก
      if (code.length == 2) {
        countries.add(Country(code: code, name: name));
      }
    });
    return countries;
  }
}