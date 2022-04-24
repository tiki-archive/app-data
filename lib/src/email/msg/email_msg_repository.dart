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
          'sender_id INTEGER NOT NULL, '
          'received_date_epoch INTEGER, '
          'opened_date_epoch INTEGER, '
          'account TEXT, '
          'created_epoch INTEGER NOT NULL, '
          'modified_epoch INTEGER NOT NULL, '
          'FOREIGN KEY (sender_id) REFERENCES sender(sender_id), '
          'UNIQUE (ext_message_id, account));');

  Future<int> upsert(List<EmailMsgModel> messages) async {
    if (messages.isNotEmpty) {
      Batch batch = _database.batch();
      for (var data in messages) {
        batch.rawInsert(
          'INSERT OR REPLACE INTO $_table '
          '(message_id, ext_message_id, sender_email, received_date_epoch, opened_date_epoch, to_email, created_epoch, modified_epoch) '
          'VALUES('
          '(SELECT message_id '
          'FROM $_table '
          'WHERE ext_message_id = ?1 AND to_email = ?5), '
          '?1, ?2, ?3, ?4, ?5, '
          '(SELECT IFNULL('
          '(SELECT created_epoch '
          'FROM $_table '
          'WHERE ext_message_id = ?1 AND to_email = ?5), '
          'strftime(\'%s\', \'now\') * 1000)), '
          'strftime(\'%s\', \'now\') * 1000)',
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
}
