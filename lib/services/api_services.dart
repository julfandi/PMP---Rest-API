import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';

class ApiServices {
  static const String baseUrl = 'https://api.atmaluhur.ac.id/pmp/mahasiswa';

  static Future<List<Mahasiswa>> getMahasiswa() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if(response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Mahasiswa.fromJson(e)).toList();
      }
      throw Exception('GET gagal: ${response.statusCode}');

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> tambahMahasiswa({
    required String nim,
    required String nama,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nim': nim, 'nama': nama}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}