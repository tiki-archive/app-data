/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import 'intg_strategy_google.dart';
import 'intg_strategy_interface.dart';

class IntgContext {
  final Httpp? httpp;

  IntgContext({this.httpp});

  Future<bool> isConnected(AccountModel account,
          {Function(
                  {DateTime? accessExp,
                  String? accessToken,
                  DateTime? refreshExp,
                  String? refreshToken})?
              onRefresh}) =>
      _strategy(account.provider)!.isConnected(account);

  Widget widget(
          {AccountModel? account,
          AccountModelProvider? provider,
          Function(AccountModel account)? onLink,
          Function(String? username)? onUnlink}) =>
      _strategy(account?.provider ?? provider)!
          .widget(account: account, onLink: onLink, onUnlink: onUnlink);

  IntgStrategyInterface? _strategy(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return IntgStrategyGoogle(httpp);
      default:
        return null;
    }
  }
}
