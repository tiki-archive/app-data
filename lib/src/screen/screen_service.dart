/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../provider/provider_enum.dart';
import 'screen_controller.dart';
import 'screen_model.dart';
import 'screen_presenter.dart';

class ScreenService extends ChangeNotifier {
  final ScreenModel model = ScreenModel();
  late final ScreenController controller;
  late final ScreenPresenter presenter;

  final AccountService _accountService;

  ScreenService(this._accountService) {
    controller = ScreenController(this);
    presenter = ScreenPresenter(this);
    _accountService.getAll().then((accounts) {
      model.addAll(accounts);
      //if(model.account != null) fetchInbox(account)
      notifyListeners();
    });
  }

  Future<void> saveAccount(AccountModel account) async {
    model.add(account);
    await _accountService.save(account);
    //_decisionSdk.setLinked(true);
    //fetchInbox(account);
  }

  Future<void> removeAccount(ProviderEnum type, String username) async {
    model.remove(type, username);
    await _accountService.remove(username, type.value);
    //model.account = null;
    //_decisionSdk.setLinked(false);
    notifyListeners();
  }
}
