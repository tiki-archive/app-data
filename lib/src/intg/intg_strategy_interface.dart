/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';

abstract class IntgStrategyInterface<S, M> {
  final Httpp? httpp;

  IntgStrategyInterface(this.httpp);

  S construct(
      {AccountModel? account,
      Function(AccountModel account)? onLink,
      Function(String? username)? onUnlink,
      Function(
              {String? accessToken,
              DateTime? accessExp,
              String? refreshToken,
              DateTime? refreshExp})?
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

  void onRefresh(
      {String? accessToken,
      DateTime? accessExp,
      String? refreshToken,
      DateTime? refreshExp}) {}
}
