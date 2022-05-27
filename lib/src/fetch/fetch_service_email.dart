/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../cmd_mgr/cmd_mgr_command_notification.dart';
import '../cmd_mgr/cmd_mgr_service.dart';
import '../company/company_service.dart';
import '../decision/decision_strategy_spam.dart';
import '../email/email_service.dart';
import '../email/msg/email_msg_model.dart';
import '../email/sender/email_sender_model.dart';
import '../graph/graph_strategy_email.dart';
import '../intg/intg_context.dart';
import '../intg/intg_context_email.dart';
import 'fetch_api_enum.dart';
import 'fetch_inbox_command.dart';
import 'fetch_inbox_command_notification.dart';
import 'fetch_msg_cmd.dart';
import 'fetch_msg_cmd_notification.dart';
import 'fetch_msg_cmd_notification_finish.dart';
import 'fetch_page_repository.dart';
import 'fetch_part_model.dart';
import 'fetch_part_repository.dart';

class FetchServiceEmail {
  final _log = Logger('FetchServiceEmail');
  late final FetchPartRepository _partRepository;
  late final FetchPageRepository _pageRepository;
  final Httpp _httpp;
  final EmailService _emailService;
  final CompanyService _companyService;
  final AccountService _accountService;
  final DecisionStrategySpam _decisionStrategySpam;
  final GraphStrategyEmail _graphStrategyEmail;
  final CmdMgrService _cmdMgrService;

  FetchServiceEmail(
      this._emailService,
      this._companyService,
      this._decisionStrategySpam,
      this._accountService,
      this._graphStrategyEmail,
      this._cmdMgrService,
      {Httpp? httpp})
      : _httpp = httpp ?? Httpp();

  Future<FetchServiceEmail> init(Database database) async {
    _pageRepository = FetchPageRepository(database);
    _partRepository = FetchPartRepository(database);
    await _pageRepository.createTable();
    await _partRepository.createTable();
    return this;
  }

  Future<void> index(AccountModel account, {Function()? onResult}) async {
    _throwIfNotConnected(account);
    _log.fine(
        'email index ${account.email} on ${DateTime.now().toIso8601String()}');
    IntgContextEmail intgContextEmail = IntgContextEmail(_accountService, httpp: _httpp);
    String id = FetchInboxCommand.generateId(account);
    DateTime? since = _cmdMgrService.getLastRun(id);
    String? page = (await _pageRepository.getByAccountIdAndApi(account.accountId!,_apiFromProvider(account.provider)!))?.page;
    FetchInboxCommand command = FetchInboxCommand(
        account,
        since,
        page,
        intgContextEmail
    );
    command.listeners.add(_commandListener);
    _cmdMgrService.addCommand(command);
  }

  Future<void> process(AccountModel account) async {
    _log.fine(
        'Process emails for ${account.email} on ${DateTime.now()
            .toIso8601String()}');
    if (!await IntgContext(_accountService, httpp: _httpp)
        .isConnected(account)) {
      throw 'ApiOauthAccount ${account.provider} not connected.';
    }
    List<FetchPartModel<EmailMsgModel>> parts =
    await _partRepository.getByAccountAndApi<EmailMsgModel>(
        account.accountId!,
        _apiFromProvider(account.provider)!,
            (json) => EmailMsgModel.fromMap(json),
        max: 100);
    if (parts.isNotEmpty) {
      IntgContextEmail intgContextEmail = IntgContextEmail(_accountService, httpp: _httpp);
      FetchMsgCmd fetchMsgCmd = FetchMsgCmd(
          parts,
          account,
          intgContextEmail);
      fetchMsgCmd.listeners.add(_commandListener);
      _cmdMgrService.addCommand(fetchMsgCmd);
    }
  }

  FetchApiEnum? _apiFromProvider(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return FetchApiEnum.gmail;
      case AccountModelProvider.microsoft:
        return FetchApiEnum.outlook;
      default:
        return null;
    }
  }

  Future<void> _commandListener(CmdMgrCommandNotification notification) async {
    if(notification is FetchInboxCommandNotification){
      _log.fine('indexed ${notification.messages.length} messages');
      List<FetchPartModel<EmailMsgModel>> parts = notification.messages
          .map((message) => FetchPartModel(
          extId: message.extMessageId,
          account: notification.account,
          api: _apiFromProvider(notification.account.provider),
          obj: message))
          .toList();
      await _partRepository.upsert<EmailMsgModel>(
          parts, (msg) => msg?.toMap());
      _log.fine('saved ${notification.messages.length} message indices');
    }
    if(notification is FetchMessagesCommandNotification){
        _decisionStrategySpam.addSpamCards(notification.account, notification.save);
        _graphStrategyEmail.write(notification.save);
    }
    if(notification is FetchMessagesCommandNotificationFinish){
      _finishProcess(notification.save, notification.fetch, notification.account);
    }
  }

  Future<void> _finishProcess(List<EmailMsgModel> save, List<EmailMsgModel> fetched, account) async {
    _log.fine('Fetched ${fetched.length} messages');
    Map<String, EmailSenderModel> senders = {};
    save.where((msg) => msg.sender != null && msg.sender?.email != null)
        .forEach((msg) => senders[msg.sender!.email!] = msg.sender!);
    await _saveSenders(senders, save);
    await _saveMessages(save);
    await _saveCompanies(senders);
    await _deleteProcessedParts(fetched, account);
    process(account);
  }

  Future<void> _saveMessages(save) async {
    _log.fine('Saving ${save.length} messages');
    await _emailService.upsertMessages(save);
  }

  Future<void> _saveSenders(senders, save) async {
    senders.forEach((email, sender) {
      List<DateTime?> dates = save.map((msg) {
        if (msg.sender?.email == email) return msg.receivedDate;
      }).toList();
      DateTime? since = dates.reduce((min, date) =>
      min != null && date != null && date.isBefore(min)
          ? date
          : min);
      sender.emailSince = since;
      senders[sender.email!] = sender;
    });
    _log.fine('Saving ${senders.length} senders');
    await _emailService.upsertSenders(List.of(senders.values));
  }

  Future<void> _saveCompanies(senders) async {
    Set<String> domains = {};
    for (var sender in senders.values) {
      if (sender.company?.domain != null) {
        domains.add(sender.company!.domain!);
      }
    }
    _log.fine('Saving ${domains.length} companies');
    for (String domain in domains) {
      _companyService.upsert(domain);
    }
  }

  Future<void> _deleteProcessedParts(fetched, account) async {
    int count = await _partRepository.deleteByExtIdsAndAccount(
        fetched.map((msg) => msg.extMessageId!).toList(),
        account.accountId!);
    _log.fine('finished & deleted $count parts');
  }

  void _throwIfNotConnected(AccountModel account) async {
    if (!await IntgContext(_accountService, httpp: _httpp).isConnected(account)) {
      throw '${account.email} - ${account.provider} not connected.';
    }
  }
}
