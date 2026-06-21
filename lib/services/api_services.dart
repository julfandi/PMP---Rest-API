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

  // update
  static Future<bool> updateMahasiswa({
    required int id,
    required String nim,
    required String nama,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-type' : 'application/json',
        },
        body: jsonEncode({
          'nim' : nim,
          'nama' : nama
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // delete
  static Future<bool> deleteMahasiswa(
    int id,
  ) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      return response.statusCode >= 200 && response.statusCode < 300; // baseUrl asal : https://api.atmaluhur.ac.id/pmp/mahasiswa/
    } catch (e) {
      return false;
    }
  }
}