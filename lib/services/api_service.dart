import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String? _baseUrl = dotenv.env['API_BASE_URL'];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<Map<String, String>> _getHeaders() async {
    print('API Base URL: $_baseUrl');
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    print('POST $_baseUrl$endpoint with data: $data');
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> patch(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    return await http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  Future<List<Map<String, dynamic>>> uploadTaskMediaFiles(
    List<File> files,
  ) async {
    final token = await _storage.read(key: 'access_token');
    final headers = {'Authorization': 'Bearer $token'};

    final uploadUrl = '$_baseUrl/uploads/';

    final results = <Map<String, dynamic>>[];

    for (var file in files) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
        request.headers.addAll(headers);

        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final result = json.decode(responseBody);

          // Django returns {"urls": [ ... ]}
          final urls = List<String>.from(result['urls']);

          // Loop through each returned URL
          for (final url in urls) {
            results.add({'image': url, 'order': results.length});
          }
        } else {
          throw Exception('Failed to upload file: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('File upload error: $e');
      }
    }

    return results;
  }
}
