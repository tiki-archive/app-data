/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../cmd_mgr/cmd_mgr_notification_finish.dart';
import '../cmd_mgr/cmd_mgr_service.dart';
import '../company/company_service.dart';
import '../decision/decision_strategy_spam.dart';
import '../email/email_service.dart';
import '../graph/graph_strategy_email.dart';
import 'fetch_inbox_cmd.dart';
import 'fetch_msg_cmd.dart';
import 'fetch_service_email.dart';

class FetchService {
  final List<String> _ongoing = [];
  late final CmdMgrService _cmdMgrService;
  late final FetchServiceEmail _email;

  Future<FetchService> init(
      EmailService emailService,
      CompanyService companyService,
      Database database,
      DecisionStrategySpam strategySpam,
      AccountService accountService,
      GraphStrategyEmail graphStrategyEmail,
      CmdMgrService cmdMgrService,
      {Httpp? httpp}) async {
    _cmdMgrService = cmdMgrService;
    _email = await FetchServiceEmail(
        emailService,
        companyService,
        strategySpam,
        accountService,
        graphStrategyEmail,
        _cmdMgrService,
        httpp: httpp).init(database);
    return this;
  }

  void start(AccountModel account) {
    _fetchInbox(account);
    _fetchMessages(account);
  }

  void stop() {
    _ongoing.forEach((cmdId) {
      _cmdMgrService.stopCommand(cmdId);
    });
  }

  void _fetchInbox(AccountModel account) async {
    FetchInboxCmd cmd = await _email.fetchInbox(account);
    cmd.listeners.add((notification) async {
      if(notification is CmdMgrNotificationFinish) {
        _fetchMessages(account);
        _ongoing.remove(cmd.id);
      }
    });
    _ongoing.add(cmd.id);
  }

  void _fetchMessages(AccountModel account) async {
    FetchMsgCmd? cmd = await _email.fetchMessages(account);
    if(cmd != null){
      cmd.listeners.add((notification) async {
        if(notification is CmdMgrNotificationFinish) {
          _ongoing.remove(cmd.id);
        }
      });
      _ongoing.add(cmd.id);
    }}
}
