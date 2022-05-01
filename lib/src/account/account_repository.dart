/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'account_model.dart';
import 'account_model_provider.dart';

class AccountRepository {
  static const String _table = 'auth_service_account';
  final _log = Logger('AccountRepository');

  final Database _database;

  AccountRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'account_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'username TEXT, '
          'email TEXT, '
          'display_name TEXT, '
          'provider TEXT, '
          'access_token TEXT, '
          'access_token_expiration INTEGER, '
          'refresh_token TEXT, '
          'refresh_token_expiration INTEGER, '
          'should_reconnect INTEGER, '
          'scopes TEXT, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL );');

  Future<AccountModel> update(AccountModel account, {Transaction? txn}) async {
    account.modified = DateTime.now();
    await (txn ?? _database).update(
      _table,
      account.toMap(),
      where: 'account_id = ?',
      whereArgs: [account.accountId],
    );
    return account;
  }

  Future<AccountModel> insert(AccountModel account, {Transaction? txn}) async {
    DateTime now = DateTime.now();
    account.modified = now;
    account.created = now;
    int id = await (txn ?? _database).insert(_table, account.toMap());
    account.accountId = id;
    return account;
  }

  Future<AccountModel?> getByProviderAndUsername(
      AccountModelProvider provider, String username,
      {Transaction? txn}) async {
    final List<Map<String, Object?>> rows = await (txn ?? _database).query(
        _table,
        where: "provider = ? AND username = ?",
        whereArgs: [provider.value, username]);
    if (rows.isEmpty) return null;
    return AccountModel.fromMap(rows[0]);
  }

  Future<int> deleteByEmailAndProvider(String email, String provider) async =>
      await _database.delete(_table,
          where: "provider = ? AND email = ?", whereArgs: [provider, email]);

  Future<List<AccountModel>> getAll() async {
    final List<Map<String, Object?>> rows = await _database.query(_table);
    if (rows.isEmpty) return [];
    return rows.map((e) => AccountModel.fromMap(e)).toList();
  }
}
