/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import 'strategy_google.dart';
import 'strategy_interface.dart';

class StrategyContext {
  final Httpp? httpp;

  StrategyContext({this.httpp});

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

  StrategyInterface? _strategy(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return StrategyGoogle(httpp);
      default:
        return null;
    }
  }
}
