import 'package:flutter/material.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_style/tiki_style.dart';

class Widgety extends StatelessWidget {
  final TikiData tikiData;

  Widgety(this.tikiData);

  @override
  Widget build(BuildContext context) {
    TikiStyle.init(context);
    return tikiData.widget(
        headerBar: Container(
          height: SizeProvider.instance.height(34),
          color: Colors.blue,
        ));
  }
}