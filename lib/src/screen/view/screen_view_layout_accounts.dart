/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiki_style/tiki_style.dart';

import '../../account/account_model.dart';
import '../../account/account_model_provider.dart';
import '../screen_service.dart';

class ScreenViewLayoutAccounts extends StatelessWidget {
   const ScreenViewLayoutAccounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenService service = Provider.of<ScreenService>(context);
    return Column(children: [
        ..._getConnectedAccounts(service),
        ..._getConnectionWidgets(service)

    ]);
  }

  List<Widget> _getConnectedAccounts(ScreenService service) {
    List<Widget> widgets = [];
    service.accounts.forEach((AccountModel account) => widgets.add(
        Container(
          margin: EdgeInsets.only(top: SizeProvider.instance.height(31)),
          child: service.intgContext.widget(
          account: account,
          provider: account.provider,
          onLink: (account) => service.controller.saveAccount(account),
          onUnlink: (email) => service.controller
            .removeAccount(account.provider!, email)))));
    return widgets;
  }

   List<Widget> _getConnectionWidgets(ScreenService service) {
     List<Widget> widgets = [];
     AccountModelProvider.values.forEach((provider) => widgets.add(
      Container(
          margin: EdgeInsets.only(top: SizeProvider.instance.height(15)),
          child: service.intgContext.widget(
              provider: provider,
              onLink: (account) => service.controller.saveAccount(account),
              onUnlink: (username) => service.controller
                  .removeAccount(provider, username)))));
     return widgets;
  }
}
