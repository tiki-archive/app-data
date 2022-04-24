/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'src/account/account_service.dart';
import 'src/company/company_service.dart';
import 'src/email/email_service.dart';
import 'src/enrich/enrich_service.dart';
import 'src/screen/screen_service.dart';

class Data {
  final Logger _log = Logger('data');

  final EnrichService _enrichService;
  late final ScreenService _screenService;
  late final EmailService _emailService;
  late final AccountService _accountService;
  late final CompanyService _companyService;

  Data(
      {Httpp? httpp,
      Future<void> Function(void Function(String?)? onSuccess)? refresh})
      : _enrichService = EnrichService(httpp: httpp, refresh: refresh);

  Future<Data> init(Database database) async {
    _companyService = await CompanyService(_enrichService).open(database);
    _accountService = await AccountService().open(database);
    _emailService = await EmailService().open(database);
    _screenService = await ScreenService(_accountService);
    return this;
  }

  Widget widget(Widget headerBar) => _screenService.presenter.render(headerBar);
}
