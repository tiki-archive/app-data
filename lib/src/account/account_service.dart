/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'account_model.dart';
import 'account_repository.dart';

class AccountService {
  late final AccountRepository _repository;

  static const String amplitudeProject = kDebugMode ? "App-test" : "App" ;

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
        if(found == null){
          Amplitude.getInstance().logEvent("EMAIL_ACCOUNT_ADDED");
          return _repository.insert(account, txn: txn);
        }
        account.accountId = found.accountId;
        account.created = found.created;
        // TODO total number of connected accounts
        return _repository.update(account, txn: txn);
      });

  Future<List<AccountModel>> getAll() => _repository.getAll();
}
