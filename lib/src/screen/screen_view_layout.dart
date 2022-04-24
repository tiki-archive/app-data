/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:style/style.dart';

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
        headerBar,
        Expanded(child: const ScreenViewLayoutBody())
      ]))
    ])));
  }
}
