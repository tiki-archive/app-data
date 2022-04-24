/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import 'screen_service.dart';

class ScreenController {
  final ScreenService service;

  ScreenController(this.service);

  Future<void> removeAccount(String email, String provider) =>
      service.removeAccount(email, provider);

  Future<void> saveAccount(AccountModel account) =>
      service.saveAccount(account);
}
