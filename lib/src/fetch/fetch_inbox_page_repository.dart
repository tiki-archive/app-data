/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'fetch_api_enum.dart';
import 'fetch_last_model.dart';

class FetchLastRepository {
  static const String _table = 'fetch_inbox_page';

  final Database _database;

  FetchLastRepository(this._database);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'fetch_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'account_id INTEGER NOT NULL, '
          'api_enum TEXT NOT NULL, '
          'page STRING NOT NULL, '
          'UNIQUE (account_id, api_enum));');

  Future<FetchLastModel> upsert(FetchLastModel data) async {
    int id = await _database.rawInsert(
        'INSERT INTO $_table'
            '(account_id, api_enum, fetched_epoch) '
            'VALUES(?1, ?2, strftime(\'%s\', \'now\') * 1000) '
            'ON CONFLICT(account_id, api_enum) DO UPDATE SET '
            'fetched_epoch=strftime(\'%s\', \'now\') * 1000 '
            'WHERE account_id = ?1 AND api_enum = ?2;',
        [data.account!.accountId, data.api?.value]);
    data.fetchId = id;
    return data;
  }

  Future<FetchLastModel?> getByAccountIdAndApi(
      int accountId, FetchApiEnum api) async {
    final List<Map<String, Object?>> rows = await _select(
        where: "last.account_id = ?1 AND api_enum = ?2",
        whereArgs: [accountId, api.value]);
    if (rows.isEmpty) return null;
    return FetchLastModel.fromMap(rows[0]);
  }

  Future<List<Map<String, Object?>>> _select(
      {String? where, List<Object?>? whereArgs, int? limit}) async {
    List<Map<String, Object?>> rows = await _database.rawQuery(
        'SELECT last.fetch_id AS \'last@fetch_id\', '
            'last.api_enum AS \'last@api_enum\', '
            'last.fetched_epoch AS \'last@fetched_epoch\', '
            'account.account_id AS \'account@account_id\', '
            'account.username AS \'account@username\', '
            'account.email AS \'account@email\', '
            'account.display_name AS \'account@display_name\', '
            'account.provider AS \'account@provider\', '
            'account.access_token AS \'account@access_token\', '
            'account.access_token_expiration AS \'account@access_token_expiration\', '
            'account.refresh_token AS \'account@refresh_token\', '
            'account.refresh_token_expiration AS \'account@refresh_token_expiration\', '
            'account.should_reconnect AS \'account@should_reconnect\', '
            'account.scopes AS \'account@scopes\', '
            'account.created_epoch AS \'account@created_epoch\', '
            'account.modified_epoch AS \'account@modified_epoch\' '
            'FROM $_table AS last '
            'LEFT JOIN auth_service_account AS account '
            'ON last.account_id = account.account_id ' +
            (where != null ? 'WHERE ' + where : '') +
            (limit != null ? 'LIMIT ' + limit.toString() : ''),
        whereArgs);
    if (rows.isEmpty) return List.empty();
    return rows.map((row) {
      Map<String, Object?> lastMap = {};
      Map<String, Object?> accountMap = {};
      for (var element in row.entries) {
        if (element.key.contains('last@')) {
          lastMap[element.key.replaceFirst('last@', '')] = element.value;
        } else if (element.key.contains('account@')) {
          accountMap[element.key.replaceFirst('account@', '')] = element.value;
        }
      }
      lastMap['account'] = accountMap;
      return lastMap;
    }).toList();
  }
}
