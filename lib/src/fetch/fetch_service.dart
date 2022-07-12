/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../email/msg/email_msg_model.dart';
import 'fetch_model_page.dart';
import 'fetch_model_part.dart';
import 'fetch_repository_page.dart';
import 'fetch_repository_part.dart';

class FetchService {

  final _log = Logger('FetchService');
  late final FetchRepositoryPart _partRepository;
  late final FetchRepositoryPage _pageRepository;

  Future<FetchService> init(Database database) async {
    _pageRepository = FetchRepositoryPage(database);
    _partRepository = FetchRepositoryPart(database);
    await _pageRepository.createTable();
    await _partRepository.createTable();
    return this;
  }

  Future<List<FetchModelPart<EmailMsgModel>>> getParts(
      AccountModel account
      ) async => await _partRepository.getByAccountAndApi<EmailMsgModel>(
        account.accountId!,
        account.emailApi!,
        (json) => EmailMsgModel.fromMap(json),
        max: 100);

  // Counts how many messages there are
  Future<int> countParts(AccountModel account) async =>
      await _partRepository.countByAccountAndApi(
          account.accountId!,
          account.emailApi!);

  Future<void> saveParts(
      List<FetchModelPart<EmailMsgModel>> msgs, AccountModel account
      ) async =>
      await _partRepository.upsert<EmailMsgModel>(msgs, (msg) => msg?.toMap());

  Future<void> deleteParts(
      List<EmailMsgModel> msgs, AccountModel account
      ) async =>
      await _partRepository.deleteByExtIdsAndAccount(
        msgs.map((msg) => msg.extMessageId!).toList(),
        account.accountId!).then((count) =>
          _log.fine('deleted $count parts'));

  Future<void> savePage(String page, AccountModel account) async =>
      await _pageRepository.upsert(
        FetchModelPage(
            account: account,
            api: account.emailApi,
            page: page
        )
      );

  Future<String?> getPage(AccountModel account) async =>
      (await _pageRepository.getByAccountIdAndApi(
          account.accountId!,account.emailApi!))?.page;

}
