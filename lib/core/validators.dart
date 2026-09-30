import '../l10n/app_localizations.dart';

/// Form validators returning a localised error message or `null`.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phone = RegExp(r'^\+?[0-9\s().\-]{6,20}$');

  static const int messageMinLength = 10;
  static const int maxLength = 200;
  static const int messageMaxLength = 3000;

  static String? required(AppLocalizations l, String? value) {
    if (value == null || value.trim().isEmpty) return l.valRequired;
    return null;
  }

  static String? email(AppLocalizations l, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valRequired;
    if (!_email.hasMatch(v)) return l.valEmail;
    return null;
  }

  /// Phone is optional; validated only when provided.
  static String? optionalPhone(AppLocalizations l, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (!_phone.hasMatch(v) || digits.length < 6) return l.valPhone;
    return null;
  }

  static String? message(AppLocalizations l, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valRequired;
    if (v.length < messageMinLength) return l.valMessageShort('$messageMinLength');
    return null;
  }
}
