/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/account/account_model.dart';
import 'package:tiki_data/src/account/account_model_provider.dart';
import 'package:tiki_data/src/account/account_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Account Tests', () {
    test('Open - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);
    });

    test('Save - Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);

      String randomEmail = Uuid().v4() + '@mytiki.com';

      AccountModel account = AccountModel(
          username: randomEmail,
          email: randomEmail,
          displayName: 'Test Name',
          provider: AccountModelProvider.google,
          shouldReconnect: true,
          modified: DateTime.now(),
          created: DateTime.now());

      AccountModel saved = await accountService.save(account);
      expect(saved.accountId != null, true);
      expect(saved.email, account.email);
      expect(saved.username, account.username);
      expect(saved.displayName, account.displayName);
      expect(saved.provider, account.provider);
      expect(saved.shouldReconnect, account.shouldReconnect);
      expect(saved.modified != null, true);
      expect(saved.created != null, true);
      expect(saved.accessToken, null);
      expect(saved.accessTokenExpiration, null);
      expect(saved.refreshToken, null);
      expect(saved.refreshTokenExpiration, null);
    });

    test('Save - Upsert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);

      String randomEmail = Uuid().v4() + '@mytiki.com';

      AccountModel account = AccountModel(
          username: randomEmail,
          email: randomEmail,
          displayName: 'Test Name',
          provider: AccountModelProvider.google,
          shouldReconnect: true,
          modified: DateTime.now(),
          created: DateTime.now());

      account = await accountService.save(account);
      account.displayName = 'New name';

      AccountModel updated = await accountService.save(account);
      expect(account.accountId, updated.accountId);
      expect(account.displayName, updated.displayName);
      expect(updated.displayName != 'Test Name', true);
    });

    test('GetAll - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);

      String randomEmail = Uuid().v4() + '@mytiki.com';

      AccountModel account = AccountModel(
          username: randomEmail,
          email: randomEmail,
          displayName: 'Test Name',
          provider: AccountModelProvider.google,
          shouldReconnect: true,
          modified: DateTime.now(),
          created: DateTime.now());

      await accountService.save(account);
      List<AccountModel> accounts = await accountService.getAll();

      expect(accounts.length, 1);
      expect(accounts.first.accountId != null, true);
      expect(accounts.first.email, account.email);
      expect(accounts.first.username, account.username);
      expect(accounts.first.displayName, account.displayName);
      expect(accounts.first.provider, account.provider);
      expect(accounts.first.shouldReconnect, account.shouldReconnect);
      expect(accounts.first.modified != null, true);
      expect(accounts.first.created != null, true);
      expect(accounts.first.accessToken, null);
      expect(accounts.first.accessTokenExpiration, null);
      expect(accounts.first.refreshToken, null);
      expect(accounts.first.refreshTokenExpiration, null);
    });

    test('GetAll - None - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);
      List<AccountModel> accounts = await accountService.getAll();
      expect(accounts.length, 0);
    });

    test('Remove - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      AccountService accountService = await AccountService().open(database);

      String randomEmail = Uuid().v4() + '@mytiki.com';

      AccountModel account = AccountModel(
          username: randomEmail,
          email: randomEmail,
          displayName: 'Test Name',
          provider: AccountModelProvider.google,
          shouldReconnect: true,
          modified: DateTime.now(),
          created: DateTime.now());

      AccountModel saved = await accountService.save(account);

      List<AccountModel> accounts = await accountService.getAll();
      expect(accounts.length, 0);
    });
  });
}
