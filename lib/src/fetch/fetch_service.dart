/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../company/company_service.dart';
import '../email/email_service.dart';
import 'fetch_service_email.dart';

class FetchService {
  final _log = Logger('FetchService');
  final Map<String, Future<dynamic>> _ongoing = Map();

  late final FetchServiceEmail _email;

  Future<FetchService> init(
      EmailService emailService,
      CompanyService companyService,
      Database database,
      TikiDecision decision,
      TikiSpamCards spamCards,
      AccountService accountService,
      {Httpp? httpp}) async {
    _email = await FetchServiceEmail(
            emailService, companyService, spamCards, decision, accountService,
            httpp: httpp)
        .init(database);
    return this;
  }

  void start(AccountModel account) {
    _emailIndex(account);
    _emailProcess(account);
  }

  void stop() {
    List<String> keys = List.from(_ongoing.keys);
    keys.forEach((key) => _ongoing.remove(key));
  }

  void _emailIndex(AccountModel account) {
    String key = 'email.index';
    _ongoing.putIfAbsent(key,
        () => _email.index(account, onResult: () => _emailProcess(account)));
  }

  void _emailProcess(AccountModel account) {
    String key = 'email.process';
    _ongoing.putIfAbsent(key, () => _email.process(account));
  }
}
