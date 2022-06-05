/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../cmd/cmd_fetch/cmd_fetch_inbox.dart';
import '../cmd/cmd_fetch/cmd_fetch_msg.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import '../cmd/cmd_mgr/cmd_mgr_service.dart';
import '../company/company_service.dart';
import '../decision/decision_strategy_spam.dart';
import '../email/email_service.dart';
import '../fetch/fetch_service.dart';
import '../graph/graph_strategy_email.dart';
import '../intg/intg_context.dart';
import 'screen_controller.dart';
import 'screen_model.dart';
import 'screen_presenter.dart';

class ScreenService extends ChangeNotifier {
  Logger _log = Logger('ScreenService');
  final ScreenModel model = ScreenModel();
  late final ScreenController controller;
  late final ScreenPresenter presenter;
  final Httpp? _httpp;

  final AccountService _accountService;
  final FetchService _fetchService;
  final DecisionStrategySpam _decisionStrategySpam;
  final EmailService _emailService;
  final CmdMgrService _cmdMgrService;
  CompanyService _companyService;

  GraphStrategyEmail _graphStrategySpam;

  ScreenService(
      this._accountService,
      this._fetchService,
      this._decisionStrategySpam,
      this._emailService,
      this._cmdMgrService,
      this._companyService,
      this._graphStrategySpam,
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
    _fetchInbox(account);
    _fetchMessages(account);
  }

  Future<void> removeAccount(AccountModelProvider type, String username) async {
    if(model.account != null) {
      _cmdMgrService.stopCommand(CmdFetchMsg.generateId(model.account!));
      _cmdMgrService.stopCommand(CmdFetchInbox.generateId(model.account!));
      model.account = null;
    }
    await _accountService.remove(username, type.value);
    await _emailService.deleteAll();
    _decisionStrategySpam.clear();
    notifyListeners();
    _decisionStrategySpam.setLinked(false);
  }

  IntgContext get intgContext => IntgContext(_accountService, httpp: _httpp);

  Future<void> _fetchInbox(AccountModel account) async {
    String? page = await _fetchService.getPage(account);
    DateTime? since = await _cmdMgrService.getLastRun(CmdFetchInbox.generateId(account));
    CmdFetchInbox cmd = CmdFetchInbox(
        _fetchService,
        account,
        since,
        page,
        _accountService,
        _httpp
    );
    _cmdMgrService.addCommand(cmd);
    cmd.listeners.add(cmdListener);
    cmd.listeners.add((notif) async {
      if(notif is CmdMgrCmdNotifFinish){
        _fetchMessages(account);
      }
    });
  }

  Future<void> _fetchMessages(AccountModel account) async{
    CmdFetchMsg cmd = CmdFetchMsg(
      account,
      _fetchService,
      _accountService,
      _emailService,
      _companyService,
      _decisionStrategySpam,
      _graphStrategySpam,
      _httpp
    );
    _cmdMgrService.addCommand(cmd);
    cmd.listeners.add(cmdListener);
  }

  Future<void> cmdListener(CmdMgrCmdNotif notif) async {
    _log.finest("received " + notif.toString());
  }
}
