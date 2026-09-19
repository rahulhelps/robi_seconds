
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    final fromEnv = const String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    return 'https://cvbuilder.kidsgrow.com.bd/api/v1';
  }
}


