class ApiConstants {
  ApiConstants._();

  /// Main app backend (documents, CV, mock test, payments, templates, ...).
  static String get baseUrl {
    final fromEnv = const String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    return 'https://cvbuilder.kidsgrow.com.bd/api/v1';
  }

  /// bdapps auth backend: send OTP, verify OTP, phone-auth, refresh,
  /// unsubscribe, /auth/me. Only `/auth/*` calls go here.
  static String get authBaseUrl {
    final fromEnv = const String.fromEnvironment('AUTH_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    return 'https://apiv2.thinkfastbd.com/api/v1';
  }

  /// Picks the backend for an API [path]: `/auth/*` -> bdapps auth backend,
  /// everything else -> main backend.
  static String urlFor(String path) =>
      path.startsWith('/auth/') ? '$authBaseUrl$path' : '$baseUrl$path';
}
