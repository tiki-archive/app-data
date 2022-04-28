/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:decision/decision.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:spam_cards/spam_cards.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../company/company_service.dart';
import '../email/email_service.dart';
import 'fetch_service_email.dart';

class FetchService {
  final _log = Logger('FetchService');
  final Set<int> _indexMutex = {};
  late final FetchServiceEmail email;

  Future<FetchService> init(
      EmailService emailService,
      CompanyService companyService,
      Database database,
      Decision decision,
      SpamCards spamCards,
      AccountService accountService,
      {Httpp? httpp}) async {
    email = await FetchServiceEmail(
            emailService, companyService, spamCards, decision, accountService,
            httpp: httpp)
        .init(database);
    return this;
  }

  Future<void> asyncIndex(AccountModel account,
      {Function(List)? onFinishProccess}) async {
    if (!_indexMutex.contains(account.accountId!)) {
      _indexMutex.add(account.accountId!);
      _log.fine(
          'DataFetchService async index for account ${account.accountId}');
      Future f1 = email.asyncIndex(account, onFinish: onFinishProccess);
      Future f2 = email.asyncProcess(account, onFinish: onFinishProccess);
      await Future.wait([f1, f2]);
      _indexMutex.remove(account.accountId!);
    }
  }
}
