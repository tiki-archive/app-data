/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';

class ScreenModel {

  List<AccountModel> accounts = List.empty(growable: true);

  List<AccountModel> pausedAccounts = List.empty(growable: true);

  Map<AccountModel, String> fetchProgress = new Map();

  ScreenModel();
}
