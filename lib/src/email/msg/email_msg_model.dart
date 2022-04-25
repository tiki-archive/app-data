/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../sender/email_sender_model.dart';

class EmailMsgModel {
  int? messageId;
  String? extMessageId;
  EmailSenderModel? sender;
  DateTime? receivedDate;
  DateTime? openedDate;
  String? toEmail;
  DateTime? created;
  DateTime? modified;

  EmailMsgModel(
      {this.messageId,
      this.extMessageId,
      this.sender,
      this.receivedDate,
      this.openedDate,
      this.toEmail,
      this.created,
      this.modified});

  EmailMsgModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      messageId = map['message_id'];
      extMessageId = map['ext_message_id'];
      sender = EmailSenderModel.fromMap(map['sender']);
      toEmail = map['to_email'];
      if (map['received_date_epoch'] != null) {
        receivedDate =
            DateTime.fromMillisecondsSinceEpoch(map['received_date_epoch']);
      }
      if (map['opened_date_epoch'] != null) {
        openedDate =
            DateTime.fromMillisecondsSinceEpoch(map['opened_date_epoch']);
      }
      if (map['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(map['modified_epoch']);
      }
      if (map['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'ext_message_id': extMessageId,
      'sender_email': sender?.email,
      'received_date_epoch': receivedDate?.millisecondsSinceEpoch,
      'opened_date_epoch': openedDate?.millisecondsSinceEpoch,
      'to_email': toEmail,
      'modified_epoch': modified?.millisecondsSinceEpoch,
      'created_epoch': created?.millisecondsSinceEpoch
    };
  }
}
