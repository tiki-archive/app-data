/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'fetch_api_enum.dart';
import 'fetch_part_model.dart';

class FetchPartRepository {
  static const String _table = 'data_fetch_part';

  final Database _database;

  FetchPartRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() => _database.execute(
      'CREATE TABLE IF NOT EXISTS $_table('
      'part_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'ext_id TEXT NOT NULL, '
      'account_id INTEGER NOT NULL, '
      'api_enum TEXT NOT NULL, '
      'obj_json TEXT, '
      'created_epoch INTEGER NOT NULL, '
      'modified_epoch INTEGER NOT NULL);'
      'CREATE UNIQUE INDEX data_fetch_part_idx ON $_table(ext_id, account_id);');

  Future<int> upsert<T>(List<FetchPartModel<T>> parts,
      Map<String, dynamic>? Function(T?) toMap) async {
    if (parts.isNotEmpty) {
      Batch batch = _database.batch();
      for (var part in parts) {
        batch.rawInsert(
          'INSERT OR REPLACE INTO $_table '
          '(part_id, ext_id, account_id, api_enum, obj_json, created_epoch, modified_epoch) '
          'VALUES('
          '(SELECT part_id '
          'FROM $_table '
          'WHERE ext_id = ?1 AND account_id = ?2), '
          '?1, ?2, ?3, ?4, '
          '(SELECT IFNULL('
          '(SELECT created_epoch '
          'FROM $_table '
          'WHERE ext_id = ?1 AND account_id = ?2), '
          'strftime(\'%s\', \'now\') * 1000)), '
          'strftime(\'%s\', \'now\') * 1000)',
          [
            part.extId,
            part.account!.accountId,
            part.api?.value,
            jsonEncode(toMap(part.obj))
          ],
        );
      }
      List res = await batch.commit(continueOnError: true);
      return res.length;
    } else {
      return 0;
    }
  }

  Future<List<FetchPartModel<T>>> getByAccountAndApi<T>(int accountId,
      FetchApiEnum api, T Function(Map<String, dynamic>? map) fromMap,
      {int? max}) async {
    final List<Map<String, Object?>> rows = await _select(
        where: 'part.api_enum = ? AND account.account_id = ? ',
        whereArgs: [api.value, accountId],
        limit: max);
    if (rows.isEmpty) return List.empty();
    return rows
        .map((e) => FetchPartModel.fromMap(e, (map) => fromMap(map)))
        .toList();
  }

  Future<int> deleteByExtIdsAndAccount(
      List<String> extIds, int accountId) async {
    int count = await _database.delete(_table,
        where: 'account_id = ? AND ext_id IN (' +
            extIds.map((id) => "'" + id + "'").join(",") +
            ')',
        whereArgs: [
          accountId,
        ]);
    return count;
  }

  Future<List<Map<String, Object?>>> _select(
      {String? where, List<Object?>? whereArgs, int? limit}) async {
    List<Map<String, Object?>> rows = await _database.rawQuery(
        'SELECT part.part_id AS \'part@part_id\', '
                'part.ext_id AS \'part@ext_id\', '
                'part.api_enum AS \'part@api_enum\', '
                'part.obj_json AS \'part@obj_json\', '
                'part.created_epoch AS \'part@created_epoch\', '
                'part.modified_epoch AS \'part@modified_epoch\', '
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
                'FROM $_table AS part '
                'INNER JOIN auth_service_account AS account '
                'ON part.account_id = account.account_id ' +
            (where != null ? 'WHERE ' + where : '') +
            (limit != null ? 'LIMIT ' + limit.toString() : ''),
        whereArgs);
    if (rows.isEmpty) return List.empty();
    return rows.map((row) {
      Map<String, Object?> partMap = {};
      Map<String, Object?> accountMap = {};
      for (var element in row.entries) {
        if (element.key.contains('part@')) {
          partMap[element.key.replaceFirst('part@', '')] = element.value;
        } else if (element.key.contains('account@')) {
          accountMap[element.key.replaceFirst('account@', '')] = element.value;
        }
      }
      partMap['account'] = accountMap;
      return partMap;
    }).toList();
  }
}
