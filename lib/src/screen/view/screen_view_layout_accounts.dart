/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiki_style/tiki_style.dart';

import '../../account/account_model.dart';
import '../../provider/provider_enum.dart';
import '../../provider/provider_google.dart';
import '../../provider/provider_microsoft.dart';
import '../screen_service.dart';

class ScreenViewLayoutAccounts extends StatelessWidget {
  const ScreenViewLayoutAccounts();

  @override
  Widget build(BuildContext context) {
    ScreenService service = Provider.of<ScreenService>(context);
    AccountModel? account = service.model.first();
    return Column(children: [
      account != null && account.provider != ProviderEnum.google.value
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(31)),
              child: ProviderGoogle(
                  account: account,
                  httpp: service.httpp,
                  onLink: (model) =>
                      service.controller.saveAccount(ProviderGoogle.to(model)),
                  onUnlink: (email) => service.controller
                      .removeAccount(ProviderEnum.google, email)).widget),
      account != null && account.provider != ProviderEnum.microsoft.value
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: SizeProvider.instance.height(15)),
              child: ProviderMicrosoft(
                  account: account,
                  httpp: service.httpp,
                  onLink: (model) => service.controller
                      .saveAccount(ProviderMicrosoft.to(model)),
                  onUnlink: (email) => service.controller
                      .removeAccount(ProviderEnum.google, email)).widget),
    ]);
  }
}
