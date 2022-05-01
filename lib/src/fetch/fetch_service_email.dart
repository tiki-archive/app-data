/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../company/company_service.dart';
import '../decision/decision_strategy_spam.dart';
import '../email/email_service.dart';
import '../email/msg/email_msg_model.dart';
import '../email/sender/email_sender_model.dart';
import '../intg/intg_context.dart';
import '../intg/intg_context_email.dart';
import 'fetch_api_enum.dart';
import 'fetch_last_model.dart';
import 'fetch_last_repository.dart';
import 'fetch_part_model.dart';
import 'fetch_part_repository.dart';

class FetchServiceEmail {
  final _log = Logger('FetchServiceEmail');
  late final FetchPartRepository _partRepository;
  late final FetchLastRepository _lastRepository;
  final Httpp _httpp;
  final EmailService _emailService;
  final CompanyService _companyService;
  final TikiSpamCards _spamCards;
  final TikiDecision _decision;
  final AccountService _accountService;

  final Set<int> _processMutex = {};

  FetchServiceEmail(this._emailService, this._companyService, this._spamCards,
      this._decision, this._accountService,
      {Httpp? httpp})
      : _httpp = httpp ?? Httpp();

  Future<FetchServiceEmail> init(Database database) async {
    _lastRepository = FetchLastRepository(database);
    _partRepository = FetchPartRepository(database);
    await _lastRepository.createTable();
    await _partRepository.createTable();
    return this;
  }

  Future<void> index(AccountModel account) async {
    if (!await IntgContext(_accountService, httpp: _httpp)
        .isConnected(account)) {
      throw '${account.email} - ${account.provider} not connected.';
    }

    _log.fine(
        'email index ${account.email} on ${DateTime.now().toIso8601String()}');
    Completer<void> completer = Completer();
    FetchLastModel? last = await _lastRepository.getByAccountIdAndApi(
        account.accountId!, _apiFromProvider(account.provider)!);
    DateTime? since = last?.fetched;

    if (since == null ||
        DateTime.now().subtract(const Duration(days: 1)).isAfter(since)) {
      DateTime fetchStart = DateTime.now();
      await IntgContextEmail(_accountService, httpp: _httpp).getInbox(
          account: account,
          since: since,
          onResult: (messages) async {
            _log.fine('indexed ${messages.length} messages');
            List<FetchPartModel<EmailMsgModel>> parts = messages
                .map((message) => FetchPartModel(
                    extId: message.extMessageId,
                    account: account,
                    api: _apiFromProvider(account.provider),
                    obj: message))
                .toList();
            await _partRepository.upsert<EmailMsgModel>(
                parts, (msg) => msg?.toMap());
            _log.fine('saved ${messages.length} message indices');
            process(account);
          },
          onFinish: () async {
            await _lastRepository.upsert(FetchLastModel(
                account: account,
                api: _apiFromProvider(account.provider),
                fetched: fetchStart));
            _log.fine('finished email index for ${account.email}.');
            completer.complete();
          });
    } else
      completer.complete();

    return completer.future;
  }

  Future<void> process(AccountModel account) async {
    Completer<void> completer = Completer();
    if (!_processMutex.contains(account.accountId!)) {
      _processMutex.add(account.accountId!);
      _log.fine(
          'Process emails for ${account.email} on ${DateTime.now().toIso8601String()}');
      _process(account,
          onProcessed: (List<EmailMsgModel> list) {
            DecisionStrategySpam(
                    _decision, _spamCards, _emailService, _accountService,
                    httpp: _httpp)
                .addSpamCards(account, list);
          },
          onFinish: () => completer.complete());
    } else
      completer.complete();
    return completer.future;
  }

  Future<void> _process(AccountModel account,
      {Function(List<EmailMsgModel>)? onProcessed,
      Function()? onFinish}) async {
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
      _log.fine('Got  ${parts.length} parts');
      List<String> ids = parts
          .where((part) => part.obj?.extMessageId != null)
          .map((part) => part.obj!.extMessageId!)
          .toList();
      List<EmailMsgModel> fetched = List.empty(growable: true);
      List<EmailMsgModel> save = List.empty(growable: true);
      await IntgContextEmail(_accountService, httpp: _httpp).getMessages(
          account: account,
          messageIds: ids,
          onResult: (message) {
            if (message.toEmail == account.email! &&
                message.sender?.unsubscribeMailTo != null) save.add(message);
            fetched.add(message);
          },
          onFinish: () async {
            _log.fine('Fetched ${fetched.length} messages');
            Map<String, EmailSenderModel> senders = {};
            save
                .where((msg) => msg.sender != null && msg.sender?.email != null)
                .forEach((msg) => senders[msg.sender!.email!] = msg.sender!);
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

            _log.fine('Saving ${save.length} messages');
            await _emailService.upsertMessages(save);

            Set<String> domains = {};
            for (var sender in senders.values) {
              if (sender.company?.domain != null) {
                domains.add(sender.company!.domain!);
              }
            }
            _log.fine('Saving ${domains.length} companies');
            for (var domain in domains) {
              _companyService.upsert(domain);
            }

            int count = await _partRepository.deleteByExtIdsAndAccount(
                fetched.map((msg) => msg.extMessageId!).toList(),
                account.accountId!);
            _log.fine('finished & deleted $count parts');
            if (onProcessed != null) {
              onProcessed(save);
            }
            _process(account, onProcessed: onProcessed);
          });
    } else {
      _processMutex.remove(account.accountId!);
      if (onFinish != null) onFinish();
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
}
