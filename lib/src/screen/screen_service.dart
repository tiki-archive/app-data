/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../cmd/cmd_fetch/cmd_fetch_inbox.dart';
import '../cmd/cmd_fetch/cmd_fetch_msg.dart';
import '../cmd/cmd_fetch/cmd_fetch_msg_notification.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif_exception.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_notif_progress_update.dart';
import '../cmd/cmd_mgr/cmd_mgr_cmd_status.dart';
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

  Amplitude? _amplitude;

  ScreenService(
      this._accountService,
      this._fetchService,
      this._decisionStrategySpam,
      this._emailService,
      this._cmdMgrService,
      this._companyService,
      this._graphStrategySpam,
      {Httpp? httpp, Amplitude? amplitude})
      : _amplitude = amplitude, _httpp = httpp {
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
    _sendConnectedAccounts();
    _decisionStrategySpam.setLinked(true);
    _decisionStrategySpam.loadFromDb(account);
    _fetchInbox(account);
    _fetchMessages(account);
  }

  Future<void> removeAccount(AccountModelProvider type, String? username) async {
    try {
      AccountModel account = _model.accounts.firstWhere((account) =>
        account.provider == type && account.email == username);
      stopCommandsFor(account);
      _model.accounts.remove(account);
      account.shouldReconnect = true;
      await _accountService.save(account);
      _decisionStrategySpam.clear();
      _decisionStrategySpam.setLinked(false);
      _sendConnectedAccounts();
    }catch (e){
      _log.warning("Account $username of ${type.runtimeType} not found");
    }
    notifyListeners();
  }

  Future<void> startCommandsFor(AccountModel account) async{
    CmdMgrCmd? cmdFetchInbox = _cmdMgrService.getById(CmdFetchInbox.generateId(account));
    if(cmdFetchInbox?.status != CmdMgrCmdStatus.running){
      _cmdMgrService.resumeCommand(cmdFetchInbox!.id);
    }else{
      await _fetchInbox(account);
    }
    CmdMgrCmd? cmdFetchMsg = _cmdMgrService.getById(CmdFetchMsg.generateId(account));
    if(cmdFetchInbox?.status != CmdMgrCmdStatus.running){
      _cmdMgrService.resumeCommand(cmdFetchMsg!.id);
    }else{
      await _fetchMessages(account);
    }
    notifyListeners();
  }

  Future<void> pauseCommandsFor(AccountModel account) async {
    CmdMgrCmd? cmdFetchInbox = _cmdMgrService.getById(CmdFetchInbox.generateId(account));
    if(cmdFetchInbox?.status == CmdMgrCmdStatus.running){
      _cmdMgrService.pauseCommand(cmdFetchInbox!.id);
    }
    CmdMgrCmd? cmdFetchMsg = _cmdMgrService.getById(CmdFetchMsg.generateId(account));
    if(cmdFetchInbox?.status == CmdMgrCmdStatus.running) {
      _cmdMgrService.pauseCommand(cmdFetchMsg!.id);
    }
    notifyListeners();
  }

  Future<void> stopCommandsFor(AccountModel account) async {
    CmdMgrCmd? cmdFetchInbox = _cmdMgrService.getById(
        CmdFetchInbox.generateId(account));
    if (cmdFetchInbox != null) {
      _cmdMgrService.stopCommand(cmdFetchInbox!.id);
      notifyListeners();
    }
  }

  Future<void> _fetchInbox(AccountModel account) async {
    _decisionStrategySpam.setPending(true);
    String? page = await _fetchService.getPage(account);
    DateTime? since = await _cmdMgrService.getLastRun(CmdFetchInbox.generateId(account));
    CmdFetchInbox cmd = CmdFetchInbox(
        _fetchService,
        account,
        since,
        page,
        _accountService,
        _httpp,
        _amplitude
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
    _decisionStrategySpam.setPending(true);
    CmdFetchMsg cmd = CmdFetchMsg(
      account,
      _fetchService,
      _accountService,
      _emailService,
      _companyService,
      _decisionStrategySpam,
      _graphStrategySpam,
      _httpp,
      _amplitude
    );
    _cmdMgrService.addCommand(cmd);
    cmd.listeners.add(_cmdListener);
    cmd.listeners.add((CmdMgrCmdNotif notif) async {
      if(notif is CmdFetchMsgNotification) {
        if (notif.fetch.length % 10 == 0) {
          _model.fetchProgress[account] = cmd.getProgressDescription();
        }
      } else if (notif is CmdMgrCmdNotifFinish) {
        _model.fetchProgress[account] = "Complete!";
      } else if (notif is CmdMgrCmdNotifException) {
        _model.fetchProgress[account] = "Fetch Failed: ${notif.exception?.toString()}";
      }
      notifyListeners();
    });
  }

  Future<void> _cmdListener(CmdMgrCmdNotif notif) async {
    _log.finest("received ${notif.runtimeType.toString()}");
    if(notif is CmdMgrCmdNotifFinish) {
      _decisionStrategySpam.setPending(false);
    }
    if(notif is CmdMgrCmdNotifException) {
      _log.warning("${notif.commandId} exception", notif.exception);
    }
  }

  void _sendConnectedAccounts() {
    if(_amplitude != null){
      _amplitude!.logEvent("CONNECTED_ACCOUNTS", eventProperties: {
        "count" : accounts.length
      });
    }
  }

  String getStatus(AccountModel? account) {
    // _log.info("Fetch progress");
    // for (CmdMgrCmd cmd in _cmdMgrService.getAll()) {
    //   if (cmd is CmdFetchMsg) {
    //     CmdFetchMsg fch = cmd;
    //
    //     _log.info("found fetch cmd w status ${fch.status.name}");
    //
    //     return fch.getProgressDescription() + " | ${fch.status.name}";
    //   }
    // }
    if (_model.fetchProgress.containsKey(account)) {
      return _model.fetchProgress[account]!;
    }
    return "Not Found";
  }

}
