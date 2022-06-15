/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'email_msg_model.dart';

class EmailMsgRepository {
  static const String _table = 'message';
  final _log = Logger('EmailRepositoryMsg');

  final Database _database;

  EmailMsgRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'message_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'ext_message_id TEXT NOT NULL, '
          'sender_email TEXT, '
          'received_date_epoch INTEGER, '
          'opened_date_epoch INTEGER, '
          'to_email TEXT NOT NULL, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL, '
          'UNIQUE (ext_message_id, to_email));');

  Future<int> upsert(List<EmailMsgModel> messages) async {
    if (messages.isNotEmpty) {
      Batch batch = _database.batch();
      for (var data in messages) {
        batch.rawInsert(
          'INSERT INTO $_table'
          '(ext_message_id, sender_email, received_date_epoch, opened_date_epoch, to_email, created_epoch, modified_epoch) '
          'VALUES(?1, ?2, ?3, ?4, ?5, strftime(\'%s\', \'now\') * 1000, strftime(\'%s\', \'now\') * 1000) '
          'ON CONFLICT(ext_message_id, to_email) DO UPDATE SET '
          'sender_email=IFNULL(?2, sender_email), '
          'received_date_epoch=IFNULL(?3, received_date_epoch), '
          'opened_date_epoch=IFNULL(?4, opened_date_epoch), '
          'modified_epoch=strftime(\'%s\', \'now\') * 1000 '
          'WHERE ext_message_id = ?1 AND to_email = ?5;',
          [
            data.extMessageId,
            data.sender?.email,
            data.receivedDate?.millisecondsSinceEpoch,
            data.openedDate?.millisecondsSinceEpoch,
            data.toEmail
          ],
        );
      }
      List res = await batch.commit(continueOnError: true);
      return res.length;
    } else {
      return 0;
    }
  }

  Future<EmailMsgModel?> getByExtMessageIdAndToDate(
      String extMessageId, String toEmail,
      {Transaction? txn}) async {
    final List<Map<String, Object?>> rows = await _select(
        where: "ext_message_id = ?1 AND to_email = ?2",
        whereArgs: [extMessageId, toEmail],
        txn: txn);
    if (rows.isEmpty) return null;
    return EmailMsgModel.fromMap(rows[0]);
  }

  Future<List<EmailMsgModel>> getBySenderEmail(String senderEmail,
      {Transaction? txn}) async {
    final List<Map<String, Object?>> rows = await _select(
        where: "sender_email = ?", whereArgs: [senderEmail], txn: txn);
    if (rows.isEmpty) return List.empty();
    return rows.map((e) => EmailMsgModel.fromMap(e)).toList();
  }

  Future<List<Map<String, Object?>>> _select(
      {String? where, List<Object?>? whereArgs, Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).rawQuery(
        'SELECT message.message_id AS \'message@message_id\', '
                'message.ext_message_id AS \'message@ext_message_id\', '
                'message.received_date_epoch AS \'message@received_date_epoch\', '
                'message.opened_date_epoch AS \'message@opened_date_epoch\', '
                'message.to_email AS \'message@to_email\', '
                'message.created_epoch AS \'message@created_epoch\', '
                'message.modified_epoch AS \'message@modified_epoch\', '
                'sender.sender_id AS \'sender@sender_id\', '
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
                'FROM message AS message '
                'LEFT JOIN sender AS sender '
                'ON message.sender_email = sender.email '
                'LEFT JOIN company AS company '
                'ON sender.company_domain = company.domain ' +
            (where != null ? 'WHERE ' + where : ''),
        whereArgs);
    if (rows.isEmpty) return List.empty();
    return rows.map((row) {
      Map<String, Object?> messageMap = {};
      Map<String, Object?> senderMap = {};
      Map<String, Object?> companyMap = {};
      for (var element in row.entries) {
        if (element.key.contains('message@')) {
          messageMap[element.key.replaceFirst('message@', '')] = element.value;
        } else if (element.key.contains('sender@')) {
          senderMap[element.key.replaceFirst('sender@', '')] = element.value;
        } else if (element.key.contains('company@')) {
          companyMap[element.key.replaceFirst('company@', '')] = element.value;
        }
      }
      senderMap['company'] = companyMap;
      messageMap['sender'] = senderMap;
      return messageMap;
    }).toList();
  }

}
