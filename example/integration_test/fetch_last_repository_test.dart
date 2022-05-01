/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/account/account_model.dart';
import 'package:tiki_data/src/account/account_service.dart';
import 'package:tiki_data/src/fetch/fetch_api_enum.dart';
import 'package:tiki_data/src/fetch/fetch_last_model.dart';
import 'package:tiki_data/src/fetch/fetch_last_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FetchLastRepository Tests', () {
    test('Upsert - New - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchLastRepository fetchLastRepository =
          await FetchLastRepository(database);
      await fetchLastRepository.createTable();

      FetchLastModel inserted = await fetchLastRepository.upsert(FetchLastModel(
          account: AccountModel(accountId: 1), api: FetchApiEnum.gmail));

      expect(inserted.fetchId != null, true);
      expect(inserted.account?.accountId, 1);
      expect(inserted.api, FetchApiEnum.gmail);
    });

    test('GetByAccountIdAndApi - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchLastRepository fetchLastRepository =
          await FetchLastRepository(database);
      await fetchLastRepository.createTable();

      await fetchLastRepository.upsert(FetchLastModel(
          account: AccountModel(accountId: 1), api: FetchApiEnum.gmail));

      FetchLastModel? inserted =
          await fetchLastRepository.getByAccountIdAndApi(1, FetchApiEnum.gmail);

      expect(inserted != null, true);
      expect(inserted?.fetchId != null, true);
      expect(inserted?.api, FetchApiEnum.gmail);
      expect(inserted?.fetched != null, true);
    });

    test('Upsert - Update - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchLastRepository fetchLastRepository =
          await FetchLastRepository(database);
      await fetchLastRepository.createTable();

      await fetchLastRepository.upsert(FetchLastModel(
          account: AccountModel(accountId: 1), api: FetchApiEnum.gmail));

      FetchLastModel? inserted =
          await fetchLastRepository.getByAccountIdAndApi(1, FetchApiEnum.gmail);

      await Future.delayed(Duration(seconds: 1));

      await fetchLastRepository.upsert(FetchLastModel(
          account: AccountModel(accountId: 1), api: FetchApiEnum.gmail));

      FetchLastModel? updated =
          await fetchLastRepository.getByAccountIdAndApi(1, FetchApiEnum.gmail);

      expect(inserted?.fetchId, updated?.fetchId);
      expect(inserted?.api, updated?.api);
      expect(updated?.fetched?.isAfter(inserted!.fetched!), true);
    });
  });
}
