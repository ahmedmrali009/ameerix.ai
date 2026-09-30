import 'package:flutter/widgets.dart';

import 'contact/contact_service.dart';

/// Minimal dependency container exposed to the widget tree.
/// Tests can inject fakes by wrapping the app with a different instance.
class AppServices extends InheritedWidget {
  const AppServices({super.key, required this.contact, required super.child});

  final ContactService contact;

  static AppServices of(BuildContext context) {
    final services = context.getInheritedWidgetOfExactType<AppServices>();
    assert(services != null, 'AppServices not found in context');
    return services!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) => oldWidget.contact != contact;
}
