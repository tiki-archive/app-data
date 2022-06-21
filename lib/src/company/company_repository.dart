/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'company_model.dart';

class CompanyRepository {
  static const String _table = 'company';

  final Database _database;

  CompanyRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'company_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'logo TEXT, '
          'security_score REAL, '
          'breach_score REAL, '
          'sensitivity_score REAL, '
          'domain TEXT UNIQUE, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL);');

  Future<CompanyModel?> getByDomain(String domain, {Transaction? txn}) async {
    final List<Map<String, Object?>> rows = await (txn ?? _database)
        .query(_table, where: "domain = ?", whereArgs: [domain]);
    if (rows.isEmpty) return null;
    return CompanyModel.fromMap(rows[0]);
  }

  Future<CompanyModel> insert(CompanyModel company, {Transaction? txn}) async {
    DateTime now = DateTime.now();
    company.modified = now;
    company.created = now;
    int id = await (txn ?? _database).insert(_table, company.toMap());
    company.companyId = id;
    return company;
  }

  Future<CompanyModel> update(CompanyModel company, {Transaction? txn}) async {
    company.modified = DateTime.now();
    await (txn ?? _database).update(
      _table,
      company.toMap(),
      where: 'company_id = ?',
      whereArgs: [company.companyId],
    );
    return company;
  }
}
