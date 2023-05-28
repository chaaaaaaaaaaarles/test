import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'back_widget.dart';
import 'base_scaffold_body.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget body;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool? showLoader;

  AppScaffold({this.appBarTitle, required this.body, this.actions, this.scaffoldBackgroundColor, this.bottomNavigationBar, this.showLoader = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        appBarTitle.validate(),
        textColor: white,
        elevation: 0.0,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: actions,
      ),
      backgroundColor: scaffoldBackgroundColor,
      body: Body(child: body, showLoader: showLoader.validate()),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
