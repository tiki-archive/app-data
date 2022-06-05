/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import 'src/account/account_model.dart';
import 'src/account/account_service.dart';
import 'src/cmd/cmd_fetch/cmd_fetch_inbox.dart';
import 'src/cmd/cmd_fetch/cmd_fetch_msg.dart';
import 'src/cmd/cmd_mgr/cmd_mgr_cmd_notif.dart';
import 'src/cmd/cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import 'src/cmd/cmd_mgr/cmd_mgr_service.dart';
import 'src/company/company_service.dart';
import 'src/decision/decision_strategy_spam.dart';
import 'src/email/email_service.dart';
import 'src/enrich/enrich_service.dart';
import 'src/fetch/fetch_service.dart';
import 'src/graph/graph_strategy_email.dart';
import 'src/screen/screen_service.dart';

class TikiData {
  Logger _log = Logger('TikiData');

  late final EnrichService _enrichService;
  late final ScreenService _screenService;
  late final EmailService _emailService;
  late final AccountService _accountService;
  late final CompanyService _companyService;
  late final FetchService _fetchService;
  late final CmdMgrService _cmdMgrService;
  late final GraphStrategyEmail _graphStrategyEmail;
  late final DecisionStrategySpam _decisionStrategySpam;
  late final Httpp _httpp;

  Future<TikiData> init(
      {required Database database,
      required TikiSpamCards spamCards,
      required TikiDecision decision,
      required TikiLocalGraph localGraph,
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      String? Function()? accessToken,
      Httpp? httpp}) async {
    _httpp = httpp ?? Httpp();
    _enrichService =
        EnrichService(httpp: httpp, refresh: refresh, accessToken: accessToken);
    _companyService = await CompanyService(_enrichService).open(database);
    _accountService = await AccountService().open(database);
    _emailService = await EmailService().open(database);
    _cmdMgrService = await CmdMgrService(database).init();
    _graphStrategyEmail = await GraphStrategyEmail(localGraph);
    _decisionStrategySpam = DecisionStrategySpam(
        decision, spamCards, _emailService, _accountService);

    _fetchService = await FetchService().init(database);

    _screenService = ScreenService(
        _accountService, _fetchService, _decisionStrategySpam, _emailService,
        _cmdMgrService,
        _companyService,
        _graphStrategyEmail,
        httpp: httpp);

    List<AccountModel> accounts = await _accountService.getAll();
    if (accounts.isNotEmpty) {
      AccountModel account = accounts.first;
      _screenService.model.account = account;
      _decisionStrategySpam.setLinked(true);
      _fetchInbox(account);
      _fetchMessages(account);
      _decisionStrategySpam.loadFromDb(account);
    }
    return this;
  }

  Widget widget({Widget? headerBar}) =>
      _screenService.presenter.render(headerBar: headerBar);

  Future<void> fetch({AccountModel? account}) async {
    AccountModel? active = account ?? _screenService.model.account;
    if(active != null) {
      _fetchInbox(active);
      _fetchMessages(active);
    }
  }

  Future<void> deleteAll() async {
    await _accountService.removeAll();
    await _emailService.deleteAll();
  }

  CmdMgrService get cmdMgrService => _cmdMgrService;

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
        _graphStrategyEmail,
        _httpp
    );
    _cmdMgrService.addCommand(cmd);
    cmd.listeners.add(_cmdListener);
  }

  Future<void> _cmdListener(CmdMgrCmdNotif notif) async {
    _log.fine("received ${notif.toString()}");
  }
}
