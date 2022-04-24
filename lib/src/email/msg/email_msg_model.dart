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

  EmailMsgModel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      messageId = json['message_id'];
      extMessageId = json['ext_message_id'];
      sender = EmailSenderModel.fromMap(json['sender']);
      toEmail = json['to_email'];
      if (json['received_date_epoch'] != null) {
        receivedDate =
            DateTime.fromMillisecondsSinceEpoch(json['received_date_epoch']);
      }
      if (json['opened_date_epoch'] != null) {
        openedDate =
            DateTime.fromMillisecondsSinceEpoch(json['opened_date_epoch']);
      }
      if (json['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(json['modified_epoch']);
      }
      if (json['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(json['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toJson() {
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
