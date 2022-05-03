/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_spam_card/tiki_spam_card.dart';

import 'src/account/account_model.dart';
import 'src/account/account_service.dart';
import 'src/company/company_service.dart';
import 'src/decision/decision_strategy_spam.dart';
import 'src/email/email_service.dart';
import 'src/enrich/enrich_service.dart';
import 'src/fetch/fetch_service.dart';
import 'src/screen/screen_service.dart';

class TikiData {
  late final EnrichService _enrichService;
  late final ScreenService _screenService;
  late final EmailService _emailService;
  late final AccountService _accountService;
  late final CompanyService _companyService;
  late final FetchService _fetchService;

  Future<TikiData> init(
      {required Database database,
      required TikiSpamCard spamCard,
      required TikiDecision decision,
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      Httpp? httpp}) async {
    _enrichService = EnrichService(httpp: httpp, refresh: refresh);
    _companyService = await CompanyService(_enrichService).open(database);
    _accountService = await AccountService().open(database);
    _emailService = await EmailService().open(database);

    DecisionStrategySpam decisionStrategySpam = DecisionStrategySpam(
        decision, spamCard, _emailService, _accountService);

    _fetchService = await FetchService().init(_emailService, _companyService,
        database, decisionStrategySpam, _accountService,
        httpp: httpp);

    _screenService = await ScreenService(
        _accountService, _fetchService, decisionStrategySpam,
        httpp: httpp);
    return this;
  }

  Widget widget({Widget? headerBar}) =>
      _screenService.presenter.render(headerBar: headerBar);

  Future<void> fetch({AccountModel? account}) async {
    AccountModel? active = account ?? _screenService.model.account;
    if (active != null) return _fetchService.start(active);
  }
}
