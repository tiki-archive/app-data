/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_provider/google_provider.dart';
import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import 'provider_enums.dart';
import 'provider_interface.dart';

class ProviderGoogle extends ProviderInterface<GoogleProviderModel> {
  final GoogleProvider _google;

  ProviderGoogle(
      {Function(GoogleProviderModel)? onLink,
      Function(String?)? onUnlink,
      Httpp? httpp})
      : _google =
            GoogleProvider(onLink: onLink, onUnlink: onUnlink, httpp: httpp);

  ProviderGoogle.loggedIn(this._google);

  @override
  Widget get widget => _google.accountWidget();

  @override
  Future<bool> isConnected(AccountModel account) async {
    Completer<bool> completer = Completer();
    _google.update(onUpdate: (account) => completer.complete(true)).timeout(
        Duration(seconds: 30),
        onTimeout: () => completer.complete(false));
    return completer.future;
  }

  static AccountModel to(GoogleProviderModel raw) => AccountModel(
        username: raw.email,
        email: raw.email,
        displayName: raw.displayName,
        provider: ProviderEnum.google.value,
        accessToken: raw.token,
        accessTokenExpiration: raw.accessTokenExp,
        refreshToken: raw.refreshToken,
      );
}
