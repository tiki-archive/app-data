/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:tiki_data/src/screen/screen_model_fetch_progress.dart';

import '../account/account_model.dart';

class ScreenModel {

  List<AccountModel> accounts = List.empty(growable: true);
  Map<AccountModel, FetchProgress> activeFetches = {};

  ScreenModel();
}
