/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:decision/decision.dart';
import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../decision/decision_strategy.dart';
import '../intg/intg_context.dart';
import 'screen_controller.dart';
import 'screen_model.dart';
import 'screen_presenter.dart';

class ScreenService extends ChangeNotifier {
  final ScreenModel model = ScreenModel();
  late final ScreenController controller;
  late final ScreenPresenter presenter;
  final Httpp? _httpp;

  final AccountService _accountService;
  final Decision _decision;
  final Future<void> Function({AccountModel account}) _fetchInbox;

  ScreenService(this._accountService, this._decision, this._fetchInbox,
      {Httpp? httpp})
      : _httpp = httpp {
    controller = ScreenController(this);
    presenter = ScreenPresenter(this);
    _accountService.getAll().then((accounts) {
      if (accounts.isNotEmpty) {
        model.account = accounts.first;
        _fetchInbox(account: model.account!);
        notifyListeners();
      }
    });
  }

  Future<void> saveAccount(AccountModel account) async {
    model.account = account;
    await _accountService.save(account);
    DecisionStrategy(_decision).setLinked(true);
    _fetchInbox(account: account);
    notifyListeners();
  }

  Future<void> removeAccount(AccountModelProvider type, String username) async {
    model.account = null;
    await _accountService.remove(username, type.value);
    DecisionStrategy(_decision).setLinked(false);
    notifyListeners();
  }

  IntgContext get intgContext => IntgContext(_accountService, httpp: _httpp);
}
