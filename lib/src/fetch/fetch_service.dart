/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../email/msg/email_msg_model.dart';
import 'fetch_api_enum.dart';
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
        apiFromProvider(account.provider)!,
        (json) => EmailMsgModel.fromMap(json),
        max: 100);

  Future<int> countParts(AccountModel account) async =>
      await _partRepository.countByAccountAndApi(
          account.accountId!,
          apiFromProvider(account.provider)!);

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

  static FetchApiEnum? apiFromProvider(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return FetchApiEnum.gmail;
      case AccountModelProvider.microsoft:
        return FetchApiEnum.outlook;
      default:
        return null;
    }
  }

  savePage(String page, AccountModel account) async =>
      await _pageRepository.upsert(
        FetchModelPage(
            account: account,
            api: apiFromProvider(account.provider!),
            page: page
        )
      );

  Future<String?> getPage(AccountModel account) async =>
      (await _pageRepository.getByAccountIdAndApi(
          account.accountId!, apiFromProvider(account.provider)!))?.page;

}
