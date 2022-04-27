/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:decision/decision.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:spam_cards/spam_cards.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
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
  final SpamCards _spamCards;
  final Decision _decision;

  final Set<int> _processMutex = {};

  FetchServiceEmail(
      this._emailService, this._companyService, this._spamCards, this._decision,
      {Httpp? httpp})
      : _httpp = httpp ?? Httpp();

  Future<FetchServiceEmail> init(Database database) async {
    _lastRepository = FetchLastRepository(database);
    _partRepository = FetchPartRepository(database);
    await _lastRepository.createTable();
    await _partRepository.createTable();
    return this;
  }

  Future<void> asyncIndex(AccountModel account,
      {Function(List)? onFinish}) async {
    _log.fine('Async index for ' +
        (account.email ?? '') +
        ' started on: ' +
        DateTime.now().toIso8601String());

    if (!await IntgContext(httpp: _httpp).isConnected(account)) {
      throw 'ApiOauthAccount ${account.provider} not connected.';
    }

    FetchLastModel? last = await _lastRepository.getByAccountIdAndApi(
        account.accountId!, _apiFromProvider(account.provider)!);
    DateTime? since = last?.fetched;

    if (since == null ||
        DateTime.now().subtract(const Duration(days: 1)).isAfter(since)) {
      DateTime fetchStart = DateTime.now();
      await IntgContextEmail(httpp: _httpp).getInbox(
          account: account,
          since: since,
          onResult: (messages) async {
            _log.fine('fetched ${messages.length} messages');
            List<FetchPartModel<EmailMsgModel>> parts = messages
                .map((message) => FetchPartModel(
                    extId: message.extMessageId,
                    account: account,
                    api: _apiFromProvider(account.provider),
                    obj: message))
                .toList();
            await _partRepository.upsert<EmailMsgModel>(
                parts, (msg) => msg?.toMap());
            _log.fine('saved ${messages.length} messages');
            asyncProcess(account, onFinish: onFinish);
          },
          onFinish: () async {
            await _lastRepository.upsert(FetchLastModel(
                account: account,
                api: _apiFromProvider(account.provider),
                fetched: fetchStart));
            _log.fine('finished fetching.');
          });
    }
  }

  Future<void> asyncProcess(AccountModel account,
      {Function(List)? onFinish}) async {
    if (!_processMutex.contains(account.accountId!)) {
      _processMutex.add(account.accountId!);
      _log.fine('Async process for ' +
          (account.email ?? '') +
          ' started on: ' +
          DateTime.now().toIso8601String());
      _asyncProcess(account, onFinish: (list) {
        DecisionStrategySpam(_decision, _spamCards, _emailService,
                httpp: _httpp)
            .addSpamCards(account, list);
        if (onFinish != null) onFinish(list);
      });
    }
  }

  Future<void> _asyncProcess(AccountModel account,
      {Function(List)? onFinish}) async {
    if (!await IntgContext(httpp: _httpp).isConnected(account)) {
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
      await IntgContextEmail(httpp: _httpp).getMessages(
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
            if (onFinish != null) {
              onFinish(save);
            }
            _asyncProcess(account, onFinish: onFinish);
          });
    } else {
      _processMutex.remove(account.accountId!);
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
