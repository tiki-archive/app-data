/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiki_style/tiki_style.dart';

import '../view/screen_view_widget_soon_img.dart';

class ScreenViewWidgetSoon extends StatelessWidget {
  static const String _title = "COMING SOON";

  const ScreenViewWidgetSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: SizeProvider.instance.height(21),
            bottom: SizeProvider.instance.height(21),
            left: SizeProvider.instance.width(38),
            right: SizeProvider.instance.width(38)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeProvider.instance.width(12)),
          //color: ColorProvider.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: TextStyle(
                  fontFamily: TextProvider.familyNunitoSans,
                  fontWeight: FontWeight.w800,
                  fontSize: SizeProvider.instance.text(17),
                  color: ColorProvider.tikiBlue,
                  package: 'tiki_style'),
            ),
            Container(
                margin: EdgeInsets.only(top: SizeProvider.instance.height(22)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.appleSoon,
                          label: 'Apple Mail'),
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.yahooSoon, label: 'Yahoo'),
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.moreSoon,
                          label: '...and more'),
                    ]))
          ],
        ));
  }
}
