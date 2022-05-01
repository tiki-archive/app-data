/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/account/account_model.dart';
import 'package:tiki_data/src/account/account_service.dart';
import 'package:tiki_data/src/email/msg/email_msg_model.dart';
import 'package:tiki_data/src/fetch/fetch_api_enum.dart';
import 'package:tiki_data/src/fetch/fetch_part_model.dart';
import 'package:tiki_data/src/fetch/fetch_part_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FetchPartRepository Tests', () {
    test('Upsert - New - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchPartRepository fetchPartRepository =
          await FetchPartRepository(database);
      await fetchPartRepository.createTable();

      EmailMsgModel msg = EmailMsgModel(messageId: 1);
      int count = await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      expect(count, 1);
    });

    test('GetByAccountAndApi - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchPartRepository fetchPartRepository =
          await FetchPartRepository(database);
      await fetchPartRepository.createTable();

      EmailMsgModel msg = EmailMsgModel(messageId: 1);
      int count = await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      List<FetchPartModel<EmailMsgModel>> parts =
          await fetchPartRepository.getByAccountAndApi(
              1, FetchApiEnum.gmail, (map) => EmailMsgModel.fromMap(map));

      expect(parts.length, 1);
      expect(parts.elementAt(0).partId != null, true);
      expect(parts.elementAt(0).extId, '1');
      expect(parts.elementAt(0).api, FetchApiEnum.gmail);
      expect(parts.elementAt(0).obj?.messageId, 1);
      expect(parts.elementAt(0).modified != null, true);
      expect(parts.elementAt(0).created != null, true);
    });

    test('Upsert - Update - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchPartRepository fetchPartRepository =
          await FetchPartRepository(database);
      await fetchPartRepository.createTable();

      EmailMsgModel msg = EmailMsgModel(messageId: 1);
      await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      List<FetchPartModel<EmailMsgModel>> inserted =
          await fetchPartRepository.getByAccountAndApi(
              1, FetchApiEnum.gmail, (map) => EmailMsgModel.fromMap(map));

      await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.outlook,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      List<FetchPartModel<EmailMsgModel>> updated =
          await fetchPartRepository.getByAccountAndApi(
              1, FetchApiEnum.outlook, (map) => EmailMsgModel.fromMap(map));

      expect(inserted.length, updated.length);
      expect(inserted.elementAt(0).partId, updated.elementAt(0).partId);
      expect(updated.elementAt(0).extId, '1');
      expect(updated.elementAt(0).api, FetchApiEnum.outlook);
    });

    test('Upsert - Multiple - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchPartRepository fetchPartRepository =
          await FetchPartRepository(database);
      await fetchPartRepository.createTable();

      EmailMsgModel msg = EmailMsgModel(messageId: 1);
      int count = await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg),
        FetchPartModel<EmailMsgModel>(
            extId: '2',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      expect(count, 2);
    });

    test('DeleteByExtIdsAndAccount - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchPartRepository fetchPartRepository =
          await FetchPartRepository(database);
      await fetchPartRepository.createTable();

      EmailMsgModel msg = EmailMsgModel(messageId: 1);
      int count = await fetchPartRepository.upsert([
        FetchPartModel<EmailMsgModel>(
            extId: '1',
            account: AccountModel(accountId: 1),
            api: FetchApiEnum.gmail,
            obj: msg)
      ], (EmailMsgModel? msg) => msg?.toMap());

      await fetchPartRepository.deleteByExtIdsAndAccount(['1'], 1);

      List<FetchPartModel<EmailMsgModel>> parts =
          await fetchPartRepository.getByAccountAndApi(
              1, FetchApiEnum.gmail, (map) => EmailMsgModel.fromMap(map));

      expect(parts.length, 0);
    });
  });
}
