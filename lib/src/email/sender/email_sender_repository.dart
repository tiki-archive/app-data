/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'email_sender_model.dart';

class EmailSenderRepository {
  static const String _table = 'sender';
  final _log = Logger('EmailRepositorySender');

  final Database _database;

  EmailSenderRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'sender_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'company_domain TEXT, '
          'name TEXT, '
          'email TEXT UNIQUE, '
          'category TEXT, '
          'unsubscribe_mail_to TEXT, '
          'ignore_until_epoch INTEGER, '
          'email_since_epoch INTEGER, '
          'updated_epoch INTEGER, '
          'unsubscribed_bool INTEGER, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL);');

  Future<EmailSenderModel?> getByEmail(String email, {Transaction? txn}) async {
    final List<Map<String, Object?>> rows =
        await _select(where: "email = ?", whereArgs: [email], txn: txn);
    if (rows.isEmpty) return null;
    return EmailSenderModel.fromMap(rows[0]);
  }

  Future<List<EmailSenderModel>> getByIgnoreUntilBefore(DateTime date,
      {Transaction? txn}) async {
    final List<Map<String, Object?>> rows = await _select(
        where: "ignore_until_epoch < ? OR ignore_until_epoch IS NULL",
        whereArgs: [date.millisecondsSinceEpoch],
        txn: txn);
    if (rows.isEmpty) return List.empty();
    return rows.map((e) => EmailSenderModel.fromMap(e)).toList();
  }

  Future<EmailSenderModel> update(EmailSenderModel sender,
      {Transaction? txn}) async {
    await (txn ?? _database).rawUpdate(
      'UPDATE $_table SET '
      'name=IFNULL(?1, name), '
      'category=IFNULL(?3, category), '
      'unsubscribe_mail_to=IFNULL(?4, unsubscribe_mail_to), '
      'ignore_until_epoch=IFNULL(?5, ignore_until_epoch), '
      'email_since_epoch=IFNULL(?6, email_since_epoch), '
      'unsubscribed_bool=IFNULL(?7, unsubscribed_bool), '
      'company_domain=IFNULL(?8, company_domain), '
      'modified_epoch=strftime(\'%s\', \'now\') * 1000 '
      'WHERE email = ?2;',
      [
        sender.name,
        sender.email,
        sender.category,
        sender.unsubscribeMailTo,
        sender.ignoreUntil?.millisecondsSinceEpoch,
        sender.emailSince?.millisecondsSinceEpoch,
        sender.unsubscribed,
        sender.company?.domain
      ],
    );
    return sender;
  }

  Future<int> upsert(List<EmailSenderModel> senders) async {
    if (senders.isNotEmpty) {
      Batch batch = _database.batch();
      for (EmailSenderModel sender in senders) {
        batch.rawInsert(
          'INSERT INTO $_table'
          '(name, email, category, unsubscribe_mail_to, ignore_until_epoch, email_since_epoch, unsubscribed_bool, company_domain, created_epoch, modified_epoch) '
          'VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, strftime(\'%s\', \'now\') * 1000, strftime(\'%s\', \'now\') * 1000) '
          'ON CONFLICT(email) DO UPDATE SET '
          'name=IFNULL(?1, name), '
          'category=IFNULL(?3, category), '
          'unsubscribe_mail_to=IFNULL(?4, unsubscribe_mail_to), '
          'ignore_until_epoch=IFNULL(?5, ignore_until_epoch), '
          'email_since_epoch=IFNULL(IIF(?6 < email_since_epoch, ?6, email_since_epoch), email_since_epoch), '
          'unsubscribed_bool=IFNULL(?7, unsubscribed_bool), '
          'company_domain=IFNULL(?8, company_domain), '
          'modified_epoch=strftime(\'%s\', \'now\') * 1000 '
          'WHERE email = ?2;',
          [
            sender.name,
            sender.email,
            sender.category,
            sender.unsubscribeMailTo,
            sender.ignoreUntil?.millisecondsSinceEpoch,
            sender.emailSince?.millisecondsSinceEpoch,
            sender.unsubscribed,
            sender.company?.domain
          ],
        );
      }
      List res = await batch.commit(continueOnError: true);
      return res.length;
    } else {
      return 0;
    }
  }

  Future<List<Map<String, Object?>>> _select(
      {String? where, List<Object?>? whereArgs, Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).rawQuery(
        'SELECT sender.sender_id AS \'sender@sender_id\', '
                'sender.name AS \'sender@name\', '
                'sender.email AS \'sender@email\', '
                'sender.category AS \'sender@category\', '
                'sender.unsubscribe_mail_to AS \'sender@unsubscribe_mail_to\', '
                'sender.email_since_epoch AS \'sender@email_since_epoch\', '
                'sender.ignore_until_epoch AS \'sender@ignore_until_epoch\', '
                'sender.unsubscribed_bool AS \'sender@unsubscribed_bool\', '
                'sender.created_epoch AS \'sender@created_epoch\', '
                'sender.modified_epoch AS \'sender@modified_epoch\', '
                'company.company_id AS \'company@company_id\', '
                'company.logo AS \'company@logo\', '
                'company.security_score AS \'company@security_score\', '
                'company.breach_score AS \'company@breach_score\', '
                'company.sensitivity_score AS \'company@sensitivity_score\', '
                'sender.company_domain AS \'company@domain\', '
                'company.created_epoch AS \'company@created_epoch\', '
                'company.modified_epoch AS \'company@modified_epoch\' '
                'FROM sender AS sender '
                'LEFT JOIN company AS company '
                'ON sender.company_domain = company.domain ' +
            (where != null ? 'WHERE ' + where : ''),
        whereArgs);
    if (rows.isEmpty) return List.empty();
    return rows.map((row) {
      Map<String, Object?> senderMap = {};
      Map<String, Object?> companyMap = {};
      for (var element in row.entries) {
        if (element.key.contains('sender@')) {
          senderMap[element.key.replaceFirst('sender@', '')] = element.value;
        } else if (element.key.contains('company@')) {
          companyMap[element.key.replaceFirst('company@', '')] = element.value;
        }
      }
      senderMap['company'] = companyMap;
      return senderMap;
    }).toList();
  }
}
