import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'reveal.dart';

/// Equal-height responsive grid.
///
/// The column count is derived from the available width and [minItemWidth],
/// capped by [maxColumns]. Items in the same row share the tallest height so
/// cards never look broken; rows respect RTL automatically.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 280,
    this.maxColumns = 3,
    this.spacing = 20,
    this.runSpacing,
    this.reveal = true,
    this.equalHeight = true,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;
  final double? runSpacing;
  final bool reveal;
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fit = ((width + spacing) / (minItemWidth + spacing)).floor();
        final columns = math.max(1, math.min(maxColumns, fit));
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final end = math.min(start + columns, children.length);
          final cells = <Widget>[];
          for (var i = start; i < start + columns; i++) {
            if (i > start) cells.add(SizedBox(width: spacing));
            if (i < end) {
              final child = reveal
                  ? Reveal(delay: Duration(milliseconds: 70 * (i - start)), child: children[i])
                  : children[i];
              cells.add(Expanded(child: child));
            } else {
              cells.add(const Expanded(child: SizedBox.shrink()));
            }
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing ?? spacing));
          final stretch = equalHeight && columns > 1;
          final row = Row(
            crossAxisAlignment: stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
            children: cells,
          );
          rows.add(stretch ? IntrinsicHeight(child: row) : row);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// Two blocks side by side on wide screens, stacked on narrow ones.
class SplitLayout extends StatelessWidget {
  const SplitLayout({
    super.key,
    required this.start,
    required this.end,
    this.breakpoint = 900,
    this.gap = 64,
    this.startFlex = 1,
    this.endFlex = 1,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.stackGap = 40,
  });

  final Widget start;
  final Widget end;
  final double breakpoint;
  final double gap;
  final int startFlex;
  final int endFlex;
  final CrossAxisAlignment crossAxisAlignment;
  final double stackGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [start, SizedBox(height: stackGap), end],
          );
        }
        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Expanded(flex: startFlex, child: start),
            SizedBox(width: gap),
            Expanded(flex: endFlex, child: end),
          ],
        );
      },
    );
  }
}
