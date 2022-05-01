/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'account_model.dart';
import 'account_repository.dart';

class AccountService {
  late final AccountRepository _repository;

  Future<AccountService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repository = AccountRepository(database);
    await _repository.createTable();
    return this;
  }

  Future<AccountModel> save(AccountModel account) =>
      _repository.transaction((txn) async {
        AccountModel? found = await _repository.getByProviderAndUsername(
            account.provider!, account.username!,
            txn: txn);
        return found == null
            ? _repository.insert(account, txn: txn)
            : _repository.update(account, txn: txn);
      });

  Future<void> remove(String email, String provider) =>
      _repository.deleteByEmailAndProvider(email, provider);

  Future<List<AccountModel>> getAll() => _repository.getAll();
}
