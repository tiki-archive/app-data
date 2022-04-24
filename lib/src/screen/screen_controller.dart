/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import '../provider/provider_enum.dart';
import '../provider/provider_interface.dart';
import 'screen_service.dart';

class ScreenController {
  final ScreenService service;

  ScreenController(this.service);

  Future<void> removeAccount(ProviderEnum type, String? username) =>
      service.removeAccount(type, username!);

  Future<void> saveAccount(AccountModel account) =>
      service.saveAccount(account);
}
