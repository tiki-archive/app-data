/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import '../account/account_model.dart';
import 'fetch_api_email_enum.dart';

class FetchModelStatus<T> {

  int? statusId;
  AccountModel? account;
  FetchEmailApiEnum? api;
  int? amount_indexed;
  int? amount_fetched;
  int? total_to_fetch;
  DateTime? created;
  DateTime? modified;

  FetchModelStatus(
      {this.statusId,
      this.account,
      this.api,
      this.amount_indexed,
      this.amount_fetched,
      this.total_to_fetch,
      this.created,
      this.modified});

  FetchModelStatus.fromMap(Map<String, dynamic>? map,
      T Function(Map<String, dynamic>? map) fromMap) {
    if (map != null) {
      statusId = map['statusId'];
      if (map['account'] != null) {
        account = AccountModel.fromMap(map['account']);
      }
      if (map['api_enum'] != null) {
        api = FetchEmailApiEnum.fromValue(map['api_enum']);
      }
      if (map['amount_indexed'] != null) {
        amount_indexed = map['amount_indexed'];
      }
      if (map['amount_fetched'] != null) {
        amount_fetched = map['amount_fetched'];
      }
      if (map['total_to_fetch'] != null) {
        total_to_fetch = map['total_to_fetch'];
      }
      if (map['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(map['modified_epoch']);
      }
      if (map['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toMap(Map<String, dynamic> Function(T?) toMap) => {
        'statusId': statusId,
        'account': account?.accountId,
        'api_enum': api?.value,
        'amount_indexed': amount_indexed,
        'amount_fetched': amount_fetched,
        'total_to_fetch': total_to_fetch,
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
