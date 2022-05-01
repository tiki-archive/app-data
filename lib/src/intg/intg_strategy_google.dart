/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:httpp/httpp.dart';
import 'package:tiki_strategy_google/tiki_strategy_google.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import 'intg_strategy_interface.dart';

class IntgStrategyGoogle
    extends IntgStrategyInterface<TikiStrategyGoogle, AuthModel> {
  static const String _redirectUri = "com.mytiki.app:/oauth";
  static const String _androidClientId =
      "240428403253-8bof2prkdatnsm8d2msgq2r81r12p5np.apps.googleusercontent.com";
  static const String _iosClientId =
      "240428403253-v4qk9lt2l07cc8am12gggocpbbsjdvl7.apps.googleusercontent.com";

  IntgStrategyGoogle(AccountService accountService, {Httpp? httpp})
      : super(accountService, httpp: httpp);

  @override
  TikiStrategyGoogle construct(
          {AccountModel? account,
          Function(AccountModel account)? onLink,
          Function(String? username)? onUnlink,
          Function(AccountModel account,
                  {DateTime? accessExp,
                  String? accessToken,
                  DateTime? refreshExp,
                  String? refreshToken})?
              onRefresh}) =>
      account != null
          ? TikiStrategyGoogle.loggedIn(
              redirectUri: _redirectUri,
              androidClientId: _androidClientId,
              iosClientId: _iosClientId,
              token: account.accessToken,
              refreshToken: account.refreshToken,
              email: account.email,
              displayName: account.displayName,
              onLink: (account) => onLinkMap(onLink, account),
              onUnlink: onUnlink,
              onRefresh: (
                  {DateTime? accessExp,
                  String? accessToken,
                  DateTime? refreshExp,
                  String? refreshToken}) {
                if (onRefresh != null)
                  onRefresh(account,
                      accessExp: accessExp,
                      accessToken: accessToken,
                      refreshToken: refreshToken,
                      refreshExp: refreshExp);
              },
              httpp: httpp)
          : TikiStrategyGoogle(
              redirectUri: _redirectUri,
              androidClientId: _androidClientId,
              iosClientId: _iosClientId,
              onLink: (account) => onLinkMap(onLink, account),
              onUnlink: onUnlink,
              httpp: httpp);

  @override
  Future<bool> isConnected(AccountModel account) {
    Completer<bool> completer = Completer();
    construct(account: account, onRefresh: onRefresh)
        .update(onUpdate: (account) => completer.complete(true))
        .timeout(Duration(seconds: 30),
            onTimeout: () => completer.complete(false));
    return completer.future;
  }

  @override
  Widget widget(
          {AccountModel? account,
          Function(AccountModel account)? onLink,
          Function(String? username)? onUnlink}) =>
      construct(
              account: account,
              onLink: onLink,
              onUnlink: onUnlink,
              onRefresh: onRefresh)
          .authButton;

  @override
  AccountModel to(AuthModel model) => AccountModel(
        username: model.email,
        email: model.email,
        displayName: model.displayName,
        provider: AccountModelProvider.google,
        accessToken: model.token,
        accessTokenExpiration: model.accessTokenExp,
        refreshToken: model.refreshToken,
      );
}
