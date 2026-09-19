import 'package:email_validator/email_validator.dart';

class CvValidators {
  static bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length >= 7 && cleaned.length <= 15;
  }

  static int? calculateAge(String? dobRaw) {
    if (dobRaw == null || dobRaw.trim().isEmpty) return null;

    final text = dobRaw.trim();
    final formats = [
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})$'),
      RegExp(r'^(\d{2})/(\d{2})/(\d{4})$'),
      RegExp(r'^(\d{2})-(\d{2})-(\d{4})$'),
    ];

    DateTime? parsed;
    for (final regex in formats) {
      final match = regex.firstMatch(text);
      if (match != null) {
        int year, month, day;
        if (regex == formats[0]) {
          year = int.parse(match[1]!);
          month = int.parse(match[2]!);
          day = int.parse(match[3]!);
        } else if (regex == formats[1]) {
          day = int.parse(match[1]!);
          month = int.parse(match[2]!);
          year = int.parse(match[3]!);
        } else {
          day = int.parse(match[1]!);
          month = int.parse(match[2]!);
          year = int.parse(match[3]!);
        }
        parsed = DateTime(year, month, day);
        break;
      }
    }

    if (parsed == null) return null;
    final today = DateTime.now();
    int age = today.year - parsed.year;
    if (today.month < parsed.month || (today.month == parsed.month && today.day < parsed.day)) {
      age--;
    }
    return age;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(value.trim())) {
      return 'Invalid phone number';
    }
    return null;
  }
}
