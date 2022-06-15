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
import '../cmd/cmd_fetch/cmd_fetch_inbox_notification.dart';
import '../cmd/cmd_fetch/cmd_fetch_msg.dart';
import '../cmd/cmd_fetch/cmd_fetch_msg_notification.dart';
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
  final ScreenModel _model = ScreenModel();
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

  get accounts => _model.accounts;

  IntgContext get intgContext => IntgContext(_accountService, httpp: _httpp);

  Future<void> addAccount(AccountModel account) async {
    account = await _accountService.save(account);
    try{
      AccountModel oldAcct = _model.accounts.firstWhere((acc) =>
        acc.provider == account.provider && acc.username == account.username);
      _model.accounts.remove(oldAcct);
      _model.accounts.add(account);
    }catch(e) {
      _model.accounts.add(account);
    }
    notifyListeners();
    _decisionStrategySpam.setLinked(true);
    _decisionStrategySpam.loadFromDb(account);
    _fetchInbox(account);
    _fetchMessages(account);
  }

  Future<void> removeAccount(AccountModelProvider type, String? username) async {
    try {
      AccountModel account = _model.accounts.firstWhere((account) =>
        account.provider == type && account.email == username);
      _cmdMgrService.stopCommand(CmdFetchMsg.generateId(account));
      _cmdMgrService.stopCommand(CmdFetchInbox.generateId(account));
      _model.accounts.remove(account);
      account.shouldReconnect = true;
      await _accountService.save(account);
      _decisionStrategySpam.clear();
    }catch (e){
      _log.warning("Account $username of ${type.runtimeType} not found");
    }
    notifyListeners();
  }

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
    cmd.listeners.add(_cmdListener);
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
    cmd.listeners.add(_cmdListener);
  }

  Future<void> _cmdListener(CmdMgrCmdNotif notif) async {
    _log.finest("received ${notif.runtimeType.toString()}");
    switch(notif.runtimeType){
      case CmdFetchInboxNotification :
        // TODO notify decisionStrategySpam
        break;
      case CmdFetchMsgNotification :
        // TODO notify decisionStrategySpam
        break;
    }
  }

}
