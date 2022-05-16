/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../decision/decision_strategy_spam.dart';
import '../email/email_service.dart';
import '../fetch/fetch_service.dart';
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
  final FetchService _fetchService;
  final DecisionStrategySpam _decisionStrategySpam;
  final EmailService _emailService;

  ScreenService(
      this._accountService, this._fetchService, this._decisionStrategySpam, this._emailService,
      {Httpp? httpp})
      : _httpp = httpp {
    controller = ScreenController(this);
    presenter = ScreenPresenter(this);
  }

  Future<void> saveAccount(AccountModel account) async {
    model.account = account;
    await _accountService.save(account);
    notifyListeners();
    _decisionStrategySpam.setLinked(true);
    _decisionStrategySpam.loadFromDb(account);
    _fetchService.start(account);
  }

  Future<void> removeAccount(AccountModelProvider type, String username) async {
    model.account = null;
    await _accountService.remove(username, type.value);
    await _emailService.removeAllEmailData();
    _decisionStrategySpam.clear();
    notifyListeners();
    _decisionStrategySpam.setLinked(false);
    _fetchService.stop();
  }

  IntgContext get intgContext => IntgContext(_accountService, httpp: _httpp);
}
