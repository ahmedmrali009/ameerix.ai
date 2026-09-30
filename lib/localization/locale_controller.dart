import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'supported_languages.dart';

/// Holds the active language and persists the visitor's choice.
///
/// Resolution order on start-up:
///  1. `?lang=xx` in the URL (shareable, used by hreflang alternates)
///  2. Previously saved choice (localStorage on web)
///  3. Browser language, if supported
///  4. English
class LocaleController extends ChangeNotifier {
  LocaleController._(this._language, this._prefs);

  SupportedLanguage _language;
  final SharedPreferences? _prefs;

  SupportedLanguage get language => _language;
  Locale get locale => _language.locale;
  bool get isRtl => _language.isRtl;

  static Future<LocaleController> create() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Storage can be unavailable (private mode, blocked cookies). The site
      // still works; the choice just isn't remembered.
      prefs = null;
    }

    String? code;
    final fromUrl = kIsWeb ? Uri.base.queryParameters['lang'] : null;
    if (isSupportedCode(fromUrl)) {
      code = fromUrl;
    } else {
      final saved = prefs?.getString(AppConfig.localeStorageKey);
      if (isSupportedCode(saved)) {
        code = saved;
      } else {
        final device = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        if (isSupportedCode(device)) code = device;
      }
    }
    return LocaleController._(languageFor(code), prefs);
  }

  /// Test/preview constructor without persistence.
  @visibleForTesting
  factory LocaleController.fixed(String code) =>
      LocaleController._(languageFor(code), null);

  Future<void> setLanguage(String code) async {
    final next = languageFor(code);
    if (next.code == _language.code) return;
    _language = next;
    notifyListeners();
    try {
      await _prefs?.setString(AppConfig.localeStorageKey, next.code);
    } catch (_) {
      // Ignore storage failures; the in-memory choice still applies.
    }
  }
}

/// Makes the [LocaleController] available to the widget tree.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({super.key, required LocaleController controller, required super.child})
      : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context');
    return scope!.notifier!;
  }

  /// Access without registering a rebuild dependency (for callbacks).
  static LocaleController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context');
    return scope!.notifier!;
  }
}
