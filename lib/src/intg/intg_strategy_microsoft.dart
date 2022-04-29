/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:httpp/httpp.dart';
import 'package:microsoft_provider/microsoft_provider.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import 'intg_strategy_interface.dart';

class IntgStrategyMicrosoft
    extends IntgStrategyInterface<MicrosoftProvider, MicrosoftProviderModel> {
  IntgStrategyMicrosoft(AccountService accountService, {Httpp? httpp})
      : super(accountService, httpp: httpp);

  @override
  MicrosoftProvider construct(
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
          ? MicrosoftProvider.loggedIn(
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
          : MicrosoftProvider(
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
  AccountModel to(MicrosoftProviderModel model) => AccountModel(
        username: model.email,
        email: model.email,
        displayName: model.displayName,
        provider: AccountModelProvider.microsoft,
        accessToken: model.token,
        accessTokenExpiration: model.accessTokenExp,
        refreshToken: model.refreshToken,
      );
}
