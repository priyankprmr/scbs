import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.master,
    this.detail,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: tablet
          ? _TwoPaneLayout(master: master, detail: detail)
          : master,
    );
  }
}

class _TwoPaneLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;

  const _TwoPaneLayout({required this.master, this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: master,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: detail ?? _emptyDetail()),
      ],
    );
  }

  Widget _emptyDetail() {
    return const Center(
      child: Text('Select an item to view details'),
    );
  }
}
