import 'package:flutter/material.dart';

import '../core/navigation.dart';
import '../l10n/app_localizations.dart';
import '../localization/locale_controller.dart';
import '../services/seo/seo_service.dart';
import '../theme/app_colors.dart';
import 'pressable.dart';
import 'site_footer.dart';
import 'site_header.dart';

/// Shared page shell: sticky header, lazily built sections, footer,
/// back-to-top control and per-page SEO metadata.
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    super.key,
    required this.path,
    required this.metaTitle,
    required this.metaDescription,
    required this.sections,
    this.indexable = true,
  });

  final String path;
  final String Function(AppLocalizations l) metaTitle;
  final String Function(AppLocalizations l) metaDescription;
  final List<Widget> sections;
  final bool indexable;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> with RouteAware {
  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> _scrolled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showTop = ValueNotifier<bool>(false);
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _controller.hasClients ? _controller.offset : 0.0;
    _scrolled.value = offset > 8;
    _showTop.value = offset > 900;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
    _scheduleSeo();
  }

  void _scheduleSeo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      final language = LocaleScope.read(context).language;
      SeoService.apply(PageMeta(
        path: widget.path,
        title: widget.metaTitle(l),
        description: widget.metaDescription(l),
        language: language,
        indexable: widget.indexable,
      ));
    });
  }

  @override
  void didPopNext() => _scheduleSeo();

  void _toTop() {
    if (!_controller.hasClients) return;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller.jumpTo(0);
    } else {
      _controller.animateTo(0, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _scrolled.dispose();
    _showTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.black,
      body: PrimaryScrollHelper(
        controller: _controller,
        child: Stack(
          children: [
            Positioned.fill(
              child: Scrollbar(
                controller: _controller,
                child: CustomScrollView(
                  controller: _controller,
                  cacheExtent: 1200,
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [...widget.sections, const SiteFooter()],
                        addRepaintBoundaries: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (context, scrolled, _) => SiteHeader(scrolled: scrolled),
              ),
            ),
            PositionedDirectional(
              end: 20,
              bottom: 20,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showTop,
                builder: (context, show, _) => IgnorePointer(
                  ignoring: !show,
                  child: AnimatedOpacity(
                    opacity: show ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: ExcludeSemantics(
                      excluding: !show,
                      child: Pressable(
                        onTap: _toTop,
                        semanticLabel: l.a11yBackToTop,
                        excludeChildSemantics: true,
                        builder: (context, s) => AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.active ? AppColors.grey300 : AppColors.white,
                            border: Border.all(color: s.focused ? AppColors.black : AppColors.lineLightStrong),
                            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6))],
                          ),
                          child: const Icon(Icons.arrow_upward, size: 20, color: AppColors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
