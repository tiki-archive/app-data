/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'fetch_api_email_enum.dart';
import 'fetch_model_status.dart';

class FetchRepositoryStatus {
  static const String _table = 'data_fetch_status';

  final Database _database;

  FetchRepositoryStatus(this._database);

  Future<void> createTable() async {
  //    _database.execute("DROP TABLE $_table");

      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'status_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'account_id INTEGER NOT NULL, '
          'api_enum TEXT NOT NULL, '
          'amount_indexed INTEGER NOT NULL, '
          'amount_fetched INTEGER NOT NULL, '
          'total_to_fetch INTEGER NOT NULL, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL, '
          'UNIQUE (account_id));');
  }

  Future<int> upsert(FetchModelStatus status) async {
    int id = await _database.rawInsert(
      'INSERT INTO $_table'
          '(account_id, api_enum, amount_indexed, amount_fetched, total_to_fetch, created_epoch, modified_epoch) '
          'VALUES(?1, ?2, IFNULL(?3, 0), IFNULL(?4, 0), IFNULL(?5, 0), strftime(\'%s\', \'now\') * 1000, strftime(\'%s\', \'now\') * 1000) '
          'ON CONFLICT(account_id) DO UPDATE SET '
          'api_enum=IFNULL(?2, api_enum), '
          'amount_indexed=IFNULL(?3, amount_indexed), '
          'amount_fetched=IFNULL(?4, amount_fetched), '
          'total_to_fetch=IFNULL(?5, total_to_fetch), '
          'modified_epoch=strftime(\'%s\', \'now\') * 1000 '
          'WHERE account_id = ?1;',
      [
        status.account!.accountId,
        status.api?.value,
        status.amount_indexed,
        status.amount_fetched,
        status.total_to_fetch
      ],
    );
    return id;
  }

  Future<FetchModelStatus<T>?> getByAccountAndApi<T>(int accountId,
      FetchEmailApiEnum api, T Function(Map<String, dynamic>? map) fromMap,
      {int? max}) async {
    final List<Map<String, Object?>> rows = await _select(
        where: 'status.api_enum = ?1 AND status.account_id = ?2 ',
        whereArgs: [api.value, accountId],
        limit: max);
    if (rows.isEmpty) return null;
    return FetchModelStatus.fromMap(rows.first, (map) => fromMap(map));
  }

  Future<int> deleteByAccount(int accountId) async {
    int count = await _database.delete(_table,
        where: 'account_id = ?',
        whereArgs: [
          accountId,
        ]);
    return count;
  }

  Future<List<Map<String, Object?>>> _select(
      {String? where, List<Object?>? whereArgs, int? limit}) async {
    List<Map<String, Object?>> rows = await _database.rawQuery(
        'SELECT status.status_id AS \'status@status_id\', '
            'status.api_enum AS \'status@api_enum\', '
            'status.amount_fetched AS \'status@amount_fetched\', '
            'status.total_to_fetch AS \'status@total_to_fetch\', '
            'status.created_epoch AS \'status@created_epoch\', '
            'status.modified_epoch AS \'status@modified_epoch\', '
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
            'FROM $_table AS status '
            'LEFT JOIN auth_service_account AS account '
            'ON status.account_id = account.account_id ' +
            (where != null ? 'WHERE ' + where : '') +
            (limit != null ? 'LIMIT ' + limit.toString() : ''),
        whereArgs);
    if (rows.isEmpty) return List.empty();
    return rows.map((row) {
      Map<String, Object?> statusMap = {};
      Map<String, Object?> accountMap = {};
      for (var element in row.entries) {
        if (element.key.contains('status@')) {
          statusMap[element.key.replaceFirst('status@', '')] = element.value;
        } else if (element.key.contains('account@')) {
          accountMap[element.key.replaceFirst('account@', '')] = element.value;
        }
      }
      statusMap['account'] = accountMap;
      return statusMap;
    }).toList();
  }

  Future<int> countByAccountAndApi(int accountId, FetchEmailApiEnum api) async {
    int count = Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) '
        'FROM $_table as status '
        'LEFT JOIN auth_service_account AS account '
        'ON status.account_id = account.account_id '
        'WHERE status.api_enum = ?1 AND status.account_id = ?2 ',
      [api.value, accountId],))!;
    return count;
  }
}
