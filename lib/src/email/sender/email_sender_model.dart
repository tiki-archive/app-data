/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../../company/company_model.dart';

class EmailSenderModel {
  int? senderId;
  CompanyModel? company;
  String? name;
  String? email;
  String? category;
  String? unsubscribeMailTo;
  DateTime? emailSince;
  bool? unsubscribed;
  DateTime? ignoreUntil;
  DateTime? created;
  DateTime? modified;

  EmailSenderModel(
      {this.senderId,
      this.company,
      this.name,
      this.email,
      this.category,
      this.unsubscribeMailTo,
      this.emailSince,
      this.unsubscribed,
      DateTime? ignoreUntil,
      this.created,
      this.modified})
      : ignoreUntil = ignoreUntil ?? DateTime.fromMillisecondsSinceEpoch(0);

  EmailSenderModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      senderId = map['sender_id'];
      company = CompanyModel.fromMap(map['company']);
      name = map['name'];
      email = map['email'];
      category = map['category'];
      unsubscribeMailTo = map['unsubscribe_mail_to'];
      unsubscribed = map['unsubscribed_bool'] == 1 ? true : false;
      if (map['ignore_until_epoch'] != null) {
        ignoreUntil =
            DateTime.fromMillisecondsSinceEpoch(map['ignore_until_epoch']);
      } else {
        ignoreUntil = DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (map['email_since_epoch'] != null) {
        emailSince =
            DateTime.fromMillisecondsSinceEpoch(map['email_since_epoch']);
      }
      if (map['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(map['modified_epoch']);
      }
      if (map['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toMap() => {
        'sender_id': senderId,
        'company_domain': company?.domain,
        'name': name,
        'email': email,
        'category': category,
        'unsubscribe_mail_to': unsubscribeMailTo,
        'email_since_epoch': emailSince?.millisecondsSinceEpoch,
        'ignore_until_epoch': ignoreUntil?.millisecondsSinceEpoch,
        'unsubscribed_bool': unsubscribed == true ? 1 : 0,
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
