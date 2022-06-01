/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import '../account/account_model.dart';
import 'fetch_api_enum.dart';

class FetchModelPart<T> {
  int? partId;
  String? extId;
  AccountModel? account;
  FetchApiEnum? api;
  T? obj;
  DateTime? created;
  DateTime? modified;

  FetchModelPart(
      {this.partId,
      this.extId,
      this.account,
      this.api,
      this.obj,
      this.created,
      this.modified});

  FetchModelPart.fromMap(Map<String, dynamic>? map,
      T Function(Map<String, dynamic>? map) fromMap) {
    if (map != null) {
      partId = map['part_id'];
      extId = map['ext_id'];
      if (map['account'] != null) {
        account = AccountModel.fromMap(map['account']);
      }
      if (map['api_enum'] != null) {
        api = FetchApiEnum.fromValue(map['api_enum']);
      }
      if (map['obj_json'] != null) {
        obj = fromMap(jsonDecode(map['obj_json']));
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
        'part_id': partId,
        'ext_id': extId,
        'account': account?.accountId,
        'api_enum': api?.value,
        'obj_json': toMap(obj),
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
