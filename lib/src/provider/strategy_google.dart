/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:google_provider/google_provider.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import 'strategy_interface.dart';

class StrategyGoogle
    extends StrategyInterface<GoogleProvider, GoogleProviderModel> {
  StrategyGoogle(Httpp? httpp) : super(httpp);

  @override
  GoogleProvider construct(
          {AccountModel? account,
          Function(AccountModel account)? onLink,
          Function(String? username)? onUnlink,
          Function(
                  {DateTime? accessExp,
                  String? accessToken,
                  DateTime? refreshExp,
                  String? refreshToken})?
              onRefresh}) =>
      account != null
          ? GoogleProvider.loggedIn(
              token: account.accessToken,
              refreshToken: account.refreshToken,
              email: account.email,
              displayName: account.displayName,
              onLink: (account) => onLinkMap(onLink, account),
              onUnlink: onUnlink,
              httpp: httpp)
          : GoogleProvider(
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
          .accountWidget();

  @override
  AccountModel to(GoogleProviderModel model) => AccountModel(
        username: model.email,
        email: model.email,
        displayName: model.displayName,
        provider: AccountModelProvider.google,
        accessToken: model.token,
        accessTokenExpiration: model.accessTokenExp,
        refreshToken: model.refreshToken,
      );
}
