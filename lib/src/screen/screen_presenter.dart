/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'screen_service.dart';
import 'view/screen_view_layout.dart';

class ScreenPresenter {
  final ScreenService service;

  ScreenPresenter(this.service);

  ChangeNotifierProvider<ScreenService> render({Widget? headerBar, bool multiple = false}) {
    return ChangeNotifierProvider.value(
        value: service, child: ScreenViewLayout(headerBar: headerBar, multiple: true));
  }
}
