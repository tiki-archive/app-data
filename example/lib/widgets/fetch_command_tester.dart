import 'package:flutter/material.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_style/tiki_style.dart';

class FetchCommandTester extends StatelessWidget {
  final TikiData tikiData;

  FetchCommandTester(this.tikiData);

  @override
  Widget build(BuildContext context) {
    TikiStyle.init(context);
    return Container();
  }
}