/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'fetch_api_enum.dart';
import 'fetch_last_model.dart';

class FetchLastRepository {
  static const String _table = 'data_fetch_last';

  final Database _database;

  FetchLastRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'fetch_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'account_id INTEGER NOT NULL, '
          'api_enum TEXT NOT NULL, '
          'fetched_epoch INTEGER NOT NULL);');

  Future<FetchLastModel> upsert(FetchLastModel data) async {
    int id = await _database.rawInsert(
        'INSERT OR REPLACE INTO $_table '
        '(fetch_id, account_id, api_enum, fetched_epoch) '
        'VALUES('
        '(SELECT fetch_id '
        'FROM $_table '
        'WHERE account_id = ?1 AND api_enum = ?2), '
        '?1, ?2,'
        'strftime(\'%s\', \'now\') * 1000)',
        [data.account!.accountId, data.api?.value]);
    data.fetchId = id;
    return data;
  }

  Future<FetchLastModel?> getByAccountIdAndApi(
      int accountId, FetchApiEnum api) async {
    final List<Map<String, Object?>> rows = await _database.query(_table,
        where: "account_id = ? AND api_enum = ?",
        whereArgs: [accountId, api.value]);
    if (rows.isNotEmpty) return null;
    return FetchLastModel.fromMap(rows[0]);
  }
}
