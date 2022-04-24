/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:tiki_style/tiki_style.dart';

class ScreenViewWidgetSoonImg extends StatelessWidget {
  final Image image;
  final String label;

  const ScreenViewWidgetSoonImg(
      {Key? key, required this.image, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: SizeProvider.instance.width(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: image.image,
              height: SizeProvider.instance.height(5.5),
              fit: BoxFit.fitHeight,
            ),
            Container(
                margin: EdgeInsets.only(top: SizeProvider.instance.height(0.5)),
                child: Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: SizeProvider.instance.text(9),
                      color: ColorProvider.tikiBlue),
                )),
          ],
        ));
  }
}
