import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../sections/shared/page_hero.dart';
import '../widgets/buttons.dart';
import '../widgets/page_scaffold.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: path,
      indexable: false,
      metaTitle: (l) => l.metaTitleNotFound,
      metaDescription: (l) => l.notFoundBody,
      sections: [
        PageHero(
          eyebrow: '404',
          title: l.notFoundTitle,
          body: l.notFoundBody,
          actions: [AppButton(label: l.backHome, route: AppRoutes.home, showArrow: true)],
        ),
      ],
    );
  }
}
