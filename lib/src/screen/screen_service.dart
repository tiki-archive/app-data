/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
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
      model.account = accounts.first;
      //if(model.account != null) fetchInbox(account)
      notifyListeners();
    });
  }

  Future<void> saveAccount(AccountModel account) async {
    model.account = await _accountService.save(account);
    //_decisionSdk.setLinked(true);
    //fetchInbox(account);
  }

  Future<void> removeAccount(String email, String provider) async {
    await _accountService.remove(email, provider);
    //model.account = null;
    //_decisionSdk.setLinked(false);
    notifyListeners();
  }
}
