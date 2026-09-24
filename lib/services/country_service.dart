import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  static const String apiUrl = 'https://flagcdn.com/en/codes.json';

  Future<List<Country>> fetchCountries() async {
    final response = await http
        .get(Uri.parse(apiUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final countries = <Country>[];
    data.forEach((code, name) {
      if (code.length == 2) {
        countries.add(Country(code: code, name: name));
      }
    });
    return countries;
  }
}