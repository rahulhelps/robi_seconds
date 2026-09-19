import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../constants.dart';
import '../storage/token_manager.dart';

class BackendService {
  static String get baseUrl => ApiConstants.baseUrl; 

  Future<List<dynamic>> getTemplates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/templates'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
    }
    return [];
  }

  Future<List<dynamic>> getLearningArticles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/learning-articles'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
    }
    return [];
  }

  Future<List<dynamic>> getJobPortals({String? category}) async {
    try {
      final uri = category != null && category.isNotEmpty && category != 'all'
          ? Uri.parse('$baseUrl/job-portals?category=$category')
          : Uri.parse('$baseUrl/job-portals');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
    }
    return [];
  }

  Future<Map<String, dynamic>> getEducationData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/education')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
    }
    return {
      'levels': [
        {'name': 'SSC'},
        {'name': 'Dakhil'},
        {'name': 'HSC'},
        {'name': 'Alim'},
        {'name': 'Diploma (Polytechnic)'},
        {'name': 'Honors/Bachelor'},
        {'name': 'Masters'},
        {'name': 'PhD'},
        {'name': 'O-Level'},
        {'name': 'A-Level'},
      ],
      'boards': [
        {'name': 'Dhaka'},
        {'name': 'Rajshahi'},
        {'name': 'Comilla'},
        {'name': 'Jessore'},
        {'name': 'Chittagong'},
        {'name': 'Sylhet'},
        {'name': 'Barisal'},
        {'name': 'Dinajpur'},
        {'name': 'Mymensingh'},
        {'name': 'Madrasah Education Board'},
        {'name': 'Bangladesh Technical Education Board (BTEB)'},
        {'name': 'Other / Autonomous'},
      ],
      'groups': [
        {'name': 'Science'},
        {'name': 'Commerce (Business Studies)'},
        {'name': 'Humanities/Arts'},
        {'name': 'Vocational'},
        {'name': 'General'},
      ],
      'grading_scales': [
        {'name': 'GPA 5.00'},
        {'name': 'CGPA 4.00'},
        {'name': 'Letter Grade'},
      ],
      'institutions': [
        {'name': 'University of Dhaka'},
        {'name': 'Bangladesh University of Engineering and Technology (BUET)'},
        {'name': 'Jahangirnagar University'},
        {'name': 'Rajshahi University'},
        {'name': 'Chittagong University'},
        {'name': 'Khulna University'},
        {'name': 'Shahjalal University of Science and Technology'},
        {'name': 'Dhaka College'},
        {'name': 'Eden Mohila College'},
        {'name': 'Rajshahi College'},
        {'name': 'Chittagong College'},
        {'name': 'Dhaka Residential Model College'},
        {'name': 'Viqarunnisa Noon School & College'},
        {'name': 'Government Madrasah-e-Alia'},
        {'name': 'Dhaka Polytechnic Institute'},
      ]
    };
  }

  Future<Map<String, dynamic>> getConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/config'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
    } catch (e) {
    }
    return {};
  }

  // --- Authenticated / Device Methods ---

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> registerDevice() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      } else {
        deviceId = 'unknown_device';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register-device'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'app_version': '1.0.0', // Can be fetched from package_info_plus
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await TokenManager.setAccessToken(token);
          return true;
        }
      }
    } catch (e) {
    }
    return false;
  }

  Future<bool> uploadCvSnapshot(Map<String, dynamic> cvData) async {
    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        // If not authenticated, attempt registration first
        final registered = await registerDevice();
        if (registered) {
          return await uploadCvSnapshot(cvData);
        }
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/cv-snapshots'),
        headers: headers,
        body: jsonEncode({
          'payload': cvData,
          'app_version': '1.0.0',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202;
    } catch (e) {
    }
    return false;
  }

  Future<Map<String, dynamic>?> getLatestCvSnapshot() async {
    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        return null; // Must be authenticated
      }

      final response = await http.get(
        Uri.parse('$baseUrl/cv-snapshots/latest'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['snapshot']?['payload'];
      }
    } catch (e) {
    }
    return null;
  }
}
