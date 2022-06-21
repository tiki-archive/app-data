/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import 'src/account/account_model.dart';
import 'src/account/account_service.dart';
import 'src/cmd/cmd_mgr/cmd_mgr_service.dart';
import 'src/company/company_service.dart';
import 'src/decision/decision_strategy_spam.dart';
import 'src/email/email_service.dart';
import 'src/enrich/enrich_service.dart';
import 'src/fetch/fetch_service.dart';
import 'src/graph/graph_strategy_email.dart';
import 'src/screen/screen_service.dart';

class TikiData {
  late final EnrichService _enrichService;
  late final ScreenService _screenService;
  late final EmailService _emailService;
  late final AccountService _accountService;
  late final CompanyService _companyService;
  late final FetchService _fetchService;
  late final CmdMgrService _cmdMgrService;
  late final GraphStrategyEmail _graphStrategyEmail;
  late final DecisionStrategySpam _decisionStrategySpam;
  late final Amplitude? _amplitude;

  Future<TikiData> init(
      {required Database database,
      required TikiSpamCards spamCards,
      required TikiDecision decision,
      required TikiLocalGraph localGraph,
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      String? Function()? accessToken,
      Httpp? httpp,
      Amplitude? amplitude}) async {
    _amplitude = amplitude;
    _enrichService =
        EnrichService(httpp: httpp, refresh: refresh, accessToken: accessToken);
    _companyService = await CompanyService(_enrichService).open(database);
    _accountService = await AccountService().open(database);
    _emailService = await EmailService().open(database);
    _cmdMgrService = await CmdMgrService(database).init();
    _graphStrategyEmail = await GraphStrategyEmail(localGraph);
    _decisionStrategySpam = DecisionStrategySpam(
        decision, spamCards, _emailService, _accountService);

    _fetchService = await FetchService().init(database);

    _screenService = ScreenService(
        _accountService, _fetchService, _decisionStrategySpam, _emailService,
        _cmdMgrService,
        _companyService,
        _graphStrategyEmail,
        amplitude: _amplitude,
        httpp: httpp);

    List<AccountModel> accounts = await _accountService.getConnected();
    if(_amplitude != null){
      _amplitude!.logEvent("CONNECTED_ACCOUNTS", eventProperties: {
        "count" : accounts.length
      });
    }
    for(AccountModel account in accounts) {
      if(!account.shouldReconnect!)
      _screenService.addAccount(account);
    }

    return this;
  }

  Widget widget({Widget? headerBar}) =>
      _screenService.presenter.render(headerBar: headerBar);

}
