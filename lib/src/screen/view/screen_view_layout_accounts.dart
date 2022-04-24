/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:google_provider/google_provider.dart';
import 'package:microsoft_provider/microsoft_provider.dart';
import 'package:provider/provider.dart';
import 'package:tiki_style/tiki_style.dart';

import '../../account/account_model.dart';
import '../../provider/provider_enums.dart';
import '../../provider/provider_google.dart';
import '../../provider/provider_microsoft.dart';
import '../screen_service.dart';

class ScreenViewLayoutAccounts extends StatelessWidget {
  const ScreenViewLayoutAccounts();

  @override
  Widget build(BuildContext context) {
    ScreenService service = Provider.of<ScreenService>(context);
    AccountModel? account = service.model.account;
    return Column(children: [
      account != null && account.provider != ProviderEnum.google.value
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(2)),
              child: account != null
                  ? ProviderGoogle.loggedIn(GoogleProvider.loggedIn(
                      token: account.accessToken,
                      refreshToken: account.refreshToken,
                      email: account.email,
                      displayName: account.displayName,
                      onLink: (model) => service.controller
                          .saveAccount(ProviderGoogle.to(model)),
                      onUnlink: (email) => service.controller
                          .removeAccount(email!, ProviderEnum.google.value),
                    )).widget
                  : ProviderGoogle(
                      onLink: (model) {
                        //ApiOAuthModelAccount account =
                        service.controller
                            .saveAccount(ProviderGoogle.to(model));
                        //service.fetchInbox(account);
                      },
                      onUnlink: (email) => account != null
                          ? service.controller
                              .removeAccount(email!, ProviderEnum.google.value)
                          : null,
                    ).widget),
      account != null && account.provider != ProviderEnum.microsoft.value
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(2)),
              child: account != null
                  ? ProviderMicrosoft.loggedIn(MicrosoftProvider.loggedIn(
                      token: account.accessToken!,
                      refreshToken: account.refreshToken,
                      email: account.email,
                      displayName: account.displayName,
                      onLink: (model) => service.controller
                          .saveAccount(ProviderMicrosoft.to(model)),
                      onUnlink: (email) => service.controller
                          .removeAccount(email!, ProviderEnum.microsoft.value),
                    )).widget
                  : ProviderMicrosoft(
                      onLink: (model) => service.controller
                          .saveAccount(ProviderMicrosoft.to(model)),
                      onUnlink: (email) => service.controller
                          .removeAccount(email!, ProviderEnum.microsoft.value),
                    ).widget),
    ]);
  }
}
