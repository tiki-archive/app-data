/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';

abstract class IntgStrategyInterface<S, M> {
  final Httpp? httpp;
  final AccountService _accountService;

  IntgStrategyInterface(this._accountService, {this.httpp});

  S construct(
      {AccountModel? account,
      Function(AccountModel account)? onLink,
      Function(String? username)? onUnlink,
      Function(AccountModel account,
              {String? accessToken,
              DateTime? accessExp,
              String? refreshToken,
              DateTime? refreshExp,
              Object? error})?
          onRefresh});

  Widget widget(
      {AccountModel? account,
      Function(AccountModel account)? onLink,
      Function(String? username)? onUnlink});

  Future<bool> isConnected(AccountModel account);

  AccountModel to(M model);

  void onLinkMap(Function(AccountModel account)? onLink, M account) {
    if (onLink != null) onLink(to(account));
  }

  Future<void> onRefresh(AccountModel account,
      {String? accessToken,
      DateTime? accessExp,
      String? refreshToken,
      DateTime? refreshExp,
      Object? error}) async {
    if(error != null) {
      account.accessToken = null;
      account.accessTokenExpiration = null;
      account.refreshToken = null;
      account.refreshTokenExpiration = null;
      account.shouldReconnect = true;
    }else{
      if (accessToken != null) account.accessToken = accessToken;
      if (accessExp != null) account.accessTokenExpiration = accessExp;
      if (refreshToken != null) account.refreshToken = refreshToken;
      if (refreshExp != null) account.refreshTokenExpiration = refreshExp;
      account.shouldReconnect = false;
    }
    await _accountService.save(account);
  }
}
