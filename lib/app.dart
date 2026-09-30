import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'core/navigation.dart';
import 'core/router.dart';
import 'l10n/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'localization/supported_languages.dart';
import 'services/app_services.dart';
import 'services/contact/contact_service.dart';
import 'theme/app_theme.dart';

class AmeerixApp extends StatelessWidget {
  const AmeerixApp({super.key, required this.localeController, this.contactService, this.initialRoute});

  final LocaleController localeController;

  /// Override for tests; defaults to the service configured at build time.
  final ContactService? contactService;

  /// Override for tests; on the web the browser URL is used.
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return AppServices(
      contact: contactService ?? ContactService.fromConfig(),
      child: LocaleScope(
        controller: localeController,
        child: ListenableBuilder(
          listenable: localeController,
          builder: (context, _) {
            final locale = localeController.locale;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
              color: const Color(0xFF030712),
              locale: locale,
              supportedLocales: [for (final lang in supportedLanguages) lang.locale],
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.forLocale(locale),
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.onGenerateRoute,
              onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
              navigatorObservers: [appRouteObserver],
              // Text scaling is honoured but bounded so layouts stay intact.
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.4)),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Exposed for tests.
const String defaultRoute = AppRoutes.home;
