/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AccountModel {
  int? accountId;
  String? username;
  String? displayName;
  String? email;
  String? provider;
  String? accessToken;
  DateTime? accessTokenExpiration;
  String? refreshToken;
  DateTime? refreshTokenExpiration;
  bool? shouldReconnect;
  DateTime? modified;
  DateTime? created;

  AccountModel(
      {this.accountId,
      this.username,
      this.displayName,
      this.email,
      this.provider,
      this.accessToken,
      this.accessTokenExpiration,
      this.refreshToken,
      this.refreshTokenExpiration,
      this.shouldReconnect,
      this.modified,
      this.created});

  AccountModel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      accountId = json['account_id'];
      username = json['username'];
      displayName = json['display_name'];
      email = json['email'];
      provider = json['provider'];
      accessToken = json['access_token'];
      refreshToken = json['refresh_token'];
      shouldReconnect = json['should_reconnect'] == 1 ? true : false;
      if (json['access_token_expiration'] != null) {
        accessTokenExpiration = DateTime.fromMillisecondsSinceEpoch(
            json['access_token_expiration']);
      }
      if (json['refresh_token_expiration'] != null) {
        refreshTokenExpiration = DateTime.fromMillisecondsSinceEpoch(
            json['refresh_token_expiration']);
      }
      if (json['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(json['modified_epoch']);
      }
      if (json['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(json['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'username': username,
        'display_name': displayName,
        'email': email,
        'provider': provider,
        'access_token': accessToken,
        'access_token_expiration':
            accessTokenExpiration?.millisecondsSinceEpoch,
        'refresh_token': refreshToken,
        'refresh_token_expiration':
            refreshTokenExpiration?.millisecondsSinceEpoch,
        'should_reconnect': shouldReconnect == true ? 1 : 0,
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
