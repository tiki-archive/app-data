/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:httpp/httpp.dart';
import 'package:microsoft_provider/microsoft_provider.dart';

import '../account/account_model.dart';
import 'provider_enums.dart';
import 'provider_interface.dart';

class ProviderMicrosoft extends ProviderInterface<MicrosoftProviderModel> {
  final MicrosoftProvider _microsoft;

  ProviderMicrosoft(
      {Function(MicrosoftProviderModel)? onLink,
      Function(String?)? onUnlink,
      Httpp? httpp})
      : _microsoft =
            MicrosoftProvider(onLink: onLink, onUnlink: onUnlink, httpp: httpp);

  ProviderMicrosoft.loggedIn(this._microsoft);

  @override
  Future<bool> isConnected(AccountModel account) {
    Completer<bool> completer = Completer();
    _microsoft.update(onUpdate: (account) => completer.complete(true)).timeout(
        Duration(seconds: 30),
        onTimeout: () => completer.complete(false));
    return completer.future;
  }

  @override
  Widget get widget => _microsoft.accountWidget();

  static AccountModel to(MicrosoftProviderModel raw) => AccountModel(
        username: raw.email,
        email: raw.email,
        displayName: raw.displayName,
        provider: ProviderEnum.microsoft.value,
        accessToken: raw.token,
        accessTokenExpiration: raw.accessTokenExp,
        refreshToken: raw.refreshToken,
      );
}
