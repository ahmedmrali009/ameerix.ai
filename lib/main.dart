import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'localization/locale_controller.dart';

Future<void> main() async {
  // Clean URLs (/platform instead of /#/platform). The host must rewrite
  // unknown paths to index.html — see README → Deployment.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Always build the semantics tree on the web: exposes headings, links and
  // labels to screen readers and gives crawlers real DOM nodes.


  final localeController = await LocaleController.create();
  runApp(AmeerixApp(localeController: localeController));
}
