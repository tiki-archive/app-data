/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import 'fetch_api_enum.dart';

class FetchPageModel {
  int? fetchId;
  AccountModel? account;
  FetchApiEnum? api;
  String? page;

  FetchPageModel({this.fetchId, this.account, this.api, this.page});

  FetchPageModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      fetchId = map['fetch_id'];
      if (map['account'] != null) {
        account = AccountModel.fromMap(map['account']);
      }
      if (map['api_enum'] != null) {
        api = FetchApiEnum.fromValue(map['api_enum']);
      }
      if (map['fetched_epoch'] != null) {
        page = map['fetched_epoch'];
      }
    }
  }

  Map<String, dynamic> toMap() => {
    'fetch_id': fetchId,
    'account': account?.accountId,
    'api_enum': api?.value,
    'page': page
  };
}
