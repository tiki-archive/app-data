/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:sqflite_sqlcipher/sqflite.dart';

import 'msg/email_msg_model.dart';
import 'msg/email_msg_repository.dart';
import 'sender/email_sender_model.dart';
import 'sender/email_sender_repository.dart';

class EmailService {
  late final EmailMsgRepository _repositoryMsg;
  late final EmailSenderRepository _repositorySender;

  static const Duration _ignoreDuration = Duration(days: 60);

  Future<EmailService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repositoryMsg = EmailMsgRepository(database);
    _repositorySender = EmailSenderRepository(database);
    await _repositoryMsg.createTable();
    await _repositorySender.createTable();
    return this;
  }

  Future<int> upsertMessages(List<EmailMsgModel> messages) async =>
      await _repositoryMsg.upsert(messages);

  Future<int> upsertSenders(List<EmailSenderModel> senders) async =>
      await _repositorySender.upsert(senders);

  Future<void> markAsUnsubscribed(EmailSenderModel sender) async {
    sender.unsubscribed = true;
    sender.ignoreUntil = DateTime.now().add(_ignoreDuration);
    _repositorySender.update(sender);
  }

  Future<void> markAsKept(EmailSenderModel sender) async {
    sender.unsubscribed = false;
    sender.ignoreUntil = DateTime.now().add(_ignoreDuration);
    _repositorySender.update(sender);
  }

  Future<EmailSenderModel?> getSenderByEmail(String email) =>
      _repositorySender.getByEmail(email);
}
