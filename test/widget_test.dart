import 'dart:convert';
import 'dart:io';

import 'package:ameerix_web/app.dart';
import 'package:ameerix_web/config/routes.dart';
import 'package:ameerix_web/core/validators.dart';
import 'package:ameerix_web/l10n/app_localizations.dart';
import 'package:ameerix_web/localization/locale_controller.dart';
import 'package:ameerix_web/localization/supported_languages.dart';
import 'package:ameerix_web/models/contact_request.dart';
import 'package:ameerix_web/services/contact/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingContactService extends ContactService {
  final List<ContactRequest> received = [];

  @override
  Future<SubmissionResult> submit(ContactRequest request) async {
    received.add(request);
    return const SubmissionResult(SubmissionStatus.success);
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  String lang = 'en',
  String route = AppRoutes.home,
  Size size = const Size(1440, 900),
  ContactService? contact,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AmeerixApp(
    localeController: LocaleController.fixed(lang),
    initialRoute: route,
    contactService: contact ?? const UnconfiguredContactService(),
  ));
  // Let reveal animations and delayed timers complete (no pumpAndSettle:
  // the corridor diagram animates continuously).
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Scrolls through the whole page so every lazily-built section is laid out
/// (layout overflows throw in tests).
Future<void> _scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  // The homepage contains tall pinned scroll scenes, so scroll far enough.
  for (var i = 0; i < 110; i++) {
    await tester.drag(scrollable, const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 300));
  }
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  const sizes = <String, Size>{
    'desktop 1440': Size(1440, 900),
    'laptop 1024': Size(1024, 768),
    'tablet 768': Size(768, 1024),
    'mobile 390': Size(390, 844),
  };

  group('every page renders without layout errors', () {
    for (final entry in sizes.entries) {
      for (final route in AppRoutes.all) {
        testWidgets('$route @ ${entry.key}', (tester) async {
          await _pumpApp(tester, route: route, size: entry.value);
          await _scrollThrough(tester);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('localisation', () {
    for (final lang in supportedLanguages) {
      testWidgets('home renders in ${lang.code} at 390 and 1440', (tester) async {
        for (final size in const [Size(390, 844), Size(1440, 900)]) {
          await _pumpApp(tester, lang: lang.code, size: size);
          await _scrollThrough(tester);
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('Arabic switches the whole app to RTL', (tester) async {
      await _pumpApp(tester, lang: 'ar');
      final context = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets('English is LTR', (tester) async {
      await _pumpApp(tester, lang: 'en');
      final context = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(context), TextDirection.ltr);
    });
  });

  group('ARB files', () {
    Map<String, dynamic> read(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;

    final en = read('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();

    for (final lang in supportedLanguages) {
      test('${lang.code} has every key and matching placeholders', () {
        final other = read(lang.code);
        final otherKeys = other.keys.where((k) => !k.startsWith('@')).toSet();
        expect(otherKeys.difference(keys), isEmpty, reason: 'extra keys');
        expect(keys.difference(otherKeys), isEmpty, reason: 'missing keys');
        final placeholder = RegExp(r'\{(\w+)\}');
        for (final k in keys) {
          final a = placeholder.allMatches(en[k] as String).map((m) => m.group(1)).toSet();
          final b = placeholder.allMatches(other[k] as String).map((m) => m.group(1)).toSet();
          expect(b, a, reason: 'placeholders differ for "$k"');
        }
      });

      test('${lang.code} hero emphasis occurs in the headline', () {
        final other = read(lang.code);
        final emphasis = other['heroEmphasis'] as String;
        expect('${other['heroLine1']} ${other['heroLine2']}'.contains(emphasis), isTrue);
      });
    }
  });

  group('contact form', () {
    testWidgets('shows validation errors and does not submit when empty', (tester) async {
      final service = _RecordingContactService();
      await _pumpApp(tester, route: AppRoutes.contact, contact: service);
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      final submit = find.text(l.submitDemo);
      await tester.ensureVisible(submit);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l.valRequired), findsWidgets);
      expect(service.received, isEmpty);
    });
  });

  group('validators', () {
    late AppLocalizations l;
    setUpAll(() async => l = await AppLocalizations.delegate.load(const Locale('en')));

    test('email', () {
      expect(Validators.email(l, ''), l.valRequired);
      expect(Validators.email(l, 'not-an-email'), l.valEmail);
      expect(Validators.email(l, 'name@company.com'), isNull);
    });

    test('phone is optional but validated', () {
      expect(Validators.optionalPhone(l, ''), isNull);
      expect(Validators.optionalPhone(l, 'abc'), l.valPhone);
      expect(Validators.optionalPhone(l, '+34 600 000 000'), isNull);
    });

    test('message length', () {
      expect(Validators.message(l, 'short'), isNotNull);
      expect(Validators.message(l, 'We export olive oil and want to enter the UAE.'), isNull);
    });
  });
}
