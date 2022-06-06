/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import 'screen_service.dart';

class ScreenController {
  final ScreenService service;

  ScreenController(this.service);

  Future<void> removeAccount(AccountModelProvider type, String? username) =>
      service.removeAccount(type, username!);

  Future<void> saveAccount(AccountModel account) =>
      service.addAccount(account);
}
