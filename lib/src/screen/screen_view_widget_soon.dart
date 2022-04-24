/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:tiki_style/tiki_style.dart';

import 'screen_view_widget_soon_img.dart';

class ScreenViewWidgetSoon extends StatelessWidget {
  static const String _title = "COMING SOON";

  const ScreenViewWidgetSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: SizeProvider.instance.height(2.5),
            bottom: SizeProvider.instance.height(3.5),
            left: SizeProvider.instance.width(7),
            right: SizeProvider.instance.width(7)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeProvider.instance.width(4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: SizeProvider.instance.text(13),
                  color: ColorProvider.tikiBlue),
            ),
            Container(
                margin: EdgeInsets.only(top: SizeProvider.instance.height(2.5)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.dataSoonApple,
                          label: 'Apple Mail'),
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.dataSoonYahoo, label: 'Yahoo'),
                      ScreenViewWidgetSoonImg(
                          image: ImgProvider.dataSoonMore,
                          label: '... and more'),
                    ]))
          ],
        ));
  }
}
