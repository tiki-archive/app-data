/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:tiki_style/tiki_style.dart';

import 'screen_view_layout_body.dart';

class ScreenViewLayout extends StatelessWidget {
  final Widget? headerBar;
  final bool multiple;

   const ScreenViewLayout({Key? key, this.headerBar, this.multiple = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Stack(children: [
      Container(color: ColorProvider.greyOne),
      SafeArea(
          child: Column(children: [
        if (headerBar != null)
          Padding(
              padding:
                  EdgeInsets.only(bottom: SizeProvider.instance.height(35)),
              child: headerBar),
        const Expanded(child: ScreenViewLayoutBody(multiple: true))
      ]))
    ])));
  }
}
