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
  final Set<int> _accountMutex = {};
  late final FetchServiceEmail email;

  Future<FetchService> init(
      EmailService emailService,
      CompanyService companyService,
      Database database,
      TikiDecision decision,
      TikiSpamCards spamCards,
      AccountService accountService,
      {Httpp? httpp}) async {
    email = await FetchServiceEmail(
            emailService, companyService, spamCards, decision, accountService,
            httpp: httpp)
        .init(database);
    return this;
  }

  Future<void> all(AccountModel account) async {
    if (!_accountMutex.contains(account.accountId!)) {
      _accountMutex.add(account.accountId!);
      _log.fine(
          'index for ${account.provider?.value} account ${account.email}');
      await Future.wait(List.from(_index(account))..addAll(_process(account)));
      _accountMutex.remove(account.accountId!);
    }
  }

  List<Future<dynamic>> _index(AccountModel account) => [email.index(account)];

  List<Future<dynamic>> _process(AccountModel account) =>
      [email.process(account)];
}
