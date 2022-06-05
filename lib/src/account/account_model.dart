/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../fetch/fetch_api_email_enum.dart';
import 'account_model_provider.dart';

class AccountModel {
  int? accountId;
  String? username;
  String? displayName;
  String? email;
  AccountModelProvider? provider;
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

  AccountModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      accountId = map['account_id'];
      username = map['username'];
      displayName = map['display_name'];
      email = map['email'];
      accessToken = map['access_token'];
      refreshToken = map['refresh_token'];
      shouldReconnect = map['should_reconnect'] == 1 ? true : false;
      if (map['provider'] != null) {
        provider = AccountModelProvider.fromValue(map['provider']);
      }
      if (map['access_token_expiration'] != null) {
        accessTokenExpiration =
            DateTime.fromMillisecondsSinceEpoch(map['access_token_expiration']);
      }
      if (map['refresh_token_expiration'] != null) {
        refreshTokenExpiration = DateTime.fromMillisecondsSinceEpoch(
            map['refresh_token_expiration']);
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
        'account_id': accountId,
        'username': username,
        'display_name': displayName,
        'email': email,
        'provider': provider?.value,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModel &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          username == other.username &&
          displayName == other.displayName &&
          email == other.email &&
          provider == other.provider &&
          accessToken == other.accessToken &&
          accessTokenExpiration == other.accessTokenExpiration &&
          refreshToken == other.refreshToken &&
          refreshTokenExpiration == other.refreshTokenExpiration &&
          shouldReconnect == other.shouldReconnect &&
          modified == other.modified &&
          created == other.created;

  @override
  int get hashCode =>
      accountId.hashCode ^
      username.hashCode ^
      displayName.hashCode ^
      email.hashCode ^
      provider.hashCode ^
      accessToken.hashCode ^
      accessTokenExpiration.hashCode ^
      refreshToken.hashCode ^
      refreshTokenExpiration.hashCode ^
      shouldReconnect.hashCode ^
      modified.hashCode ^
      created.hashCode;

  FetchEmailApiEnum? get emailApi {
    switch (provider) {
      case AccountModelProvider.google:
        return FetchEmailApiEnum.gmail;
      case AccountModelProvider.microsoft:
        return FetchEmailApiEnum.outlook;
      default:
        return null;
    }
  }
}
