/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/cmd/cmd_mgr/cmd_mgr_service.dart';
import 'package:tiki_data/src/cmd/cmd_fetch/cmd_fetch_inbox.dart';
import 'package:tiki_data/src/account/account_service.dart';
import 'package:tiki_data/src/account/account_model.dart';
import 'package:tiki_data/src/fetch/fetch_service.dart';
import 'package:tiki_data/src/cmd/cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // this test is incomplete. See https://github.com/tiki/data/issues/121
  group('CmdFetchInbox', () {
    test('Fetch from last saved page', () async {
      String? returnedPage;
      bool finished = false;
      Database database = await openDatabase('${Uuid().v4()}.db');
      await AccountService().open(database);
      FetchService fetchService = FetchService();
      AccountModel account = AccountModel();
      AccountService accountService = AccountService();
      String page = '123456';
      CmdMgrService cmdMgrService = CmdMgrService(database);
      CmdFetchInbox cmdFetchInbox = CmdFetchInbox(
          fetchService,
          account,
          null,
          page,
          accountService,
          null,
          null);
      cmdFetchInbox.listeners.add((notification) async {
        if(notification is CmdMgrCmdNotifFinish){
          finished = true;
        }
      });
    });
  });
}
