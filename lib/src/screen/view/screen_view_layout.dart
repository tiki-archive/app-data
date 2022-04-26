/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:tiki_style/tiki_style.dart';

import 'screen_view_layout_body.dart';

class ScreenViewLayout extends StatelessWidget {
  final Widget headerBar;

  const ScreenViewLayout(this.headerBar);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Stack(children: [
      Container(color: ColorProvider.greyOne),
      SafeArea(
          child: Column(children: [
        Padding(
              padding: EdgeInsets.only(bottom: SizeProvider.instance.height(35)),
              child: headerBar),
        Expanded(child: const ScreenViewLayoutBody())
      ]))
    ])));
  }
}
