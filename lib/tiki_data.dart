/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import 'src/account/account_model.dart';
import 'src/account/account_service.dart';
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

  Future<TikiData> init(
      {required Database database,
      required TikiSpamCards spamCards,
      required TikiDecision decision,
      required TikiLocalGraph localGraph,
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      String? Function()? accessToken,
      Httpp? httpp}) async {
    _enrichService =
        EnrichService(httpp: httpp, refresh: refresh, accessToken: accessToken);
    _companyService = await CompanyService(_enrichService).open(database);
    _accountService = await AccountService().open(database);
    _emailService = await EmailService().open(database);

    DecisionStrategySpam decisionStrategySpam = DecisionStrategySpam(
        decision, spamCards, _emailService, _accountService);

    _fetchService = await FetchService().init(
        _emailService,
        _companyService,
        database,
        decisionStrategySpam,
        _accountService,
        GraphStrategyEmail(localGraph),
        httpp: httpp);

    _screenService = ScreenService(
        _accountService, _fetchService, decisionStrategySpam, _emailService,
        httpp: httpp);

    List<AccountModel> accounts = await _accountService.getAll();
    if (accounts.isNotEmpty) {
        AccountModel account = accounts.first;
        _screenService.model.account = account;
        decisionStrategySpam.setLinked(true);
        _fetchService.start(account);
        await decisionStrategySpam.loadFromDb(account);
    }
    return this;
  }

  Widget widget({Widget? headerBar}) =>
      _screenService.presenter.render(headerBar: headerBar);

  Future<void> fetch({AccountModel? account}) async {
    AccountModel? active = account ?? _screenService.model.account;
    if (active != null) return _fetchService.start(active);
  }

  Future<void> removeAllData() async{
    await _accountService.removeAll();
    await _emailService.removeAllEmailData();
  }
}
