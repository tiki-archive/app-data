/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiki_style/tiki_style.dart';

import '../screen_service.dart';
import 'screen_view_layout_accounts.dart';
import 'screen_view_widget_soon.dart';
import 'screen_view_widget_state.dart';

class ScreenViewLayoutBody extends StatelessWidget {
  const ScreenViewLayoutBody();

  @override
  Widget build(BuildContext context) {
    ScreenService service = Provider.of<ScreenService>(context);
    bool isLinked = service.model.account != null;
    return GestureDetector(
        child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeProvider.instance.width(8)),
                child: Column(
                  children: [
                    ScreenViewWidgetState(
                        image: isLinked
                            ? ImgProvider.dataStateHappy
                            : ImgProvider.dataStateSad,
                        summary:
                            isLinked ? "All good!" : "Uh-oh. No data just yet!",
                        description: isLinked
                            ? "Your account is linked now. See what data ${service.model.account?.provider} holds by tapping on the button below."
                            : "Get started by adding an account",
                        color: isLinked
                            ? ColorProvider.green
                            : ColorProvider.blue),
                    const ScreenViewLayoutAccounts(),
                    Container(
                        margin: EdgeInsets.only(
                            top: SizeProvider.instance.height(2)),
                        child: const ScreenViewWidgetSoon())
                  ],
                ))));
  }
}
