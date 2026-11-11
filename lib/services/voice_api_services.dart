import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VoiceAPIService {
  final String baseUrl;

  VoiceAPIService({required this.baseUrl});

  /// Upload reference voice file (ACC/AAC/M4A)
  Future<String> uploadReference(File file) async {
    final url = Uri.parse('$baseUrl/upload-reference/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final json = jsonDecode(resBody);
      return json['message'];
    } else {
      throw Exception('Failed to upload reference voice');
    }
  }

  /// Verify test voice file (WAV)
  Future<Map<String, dynamic>> verifyVoice(File file) async {
    final url = Uri.parse('$baseUrl/verify-voice/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      return jsonDecode(resBody);
    } else {
      throw Exception('Voice verification failed');
    }
  }
}
