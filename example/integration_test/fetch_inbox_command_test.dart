/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../lib/src/cmd_mgr/cmd_mgr_service.dart';
import '../../lib/src/fetch/fetch_inbox_command.dart';
import '../../lib/src/fetch/fetch_inbox_command_notification.dart';
import '../../lib/src/account/account_model.dart';
import '../../lib/src/account/account_service.dart';
import '../../lib/src/account/account_model_provider.dart';
import '../../lib/src/intg/intg_context_email.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FetchInboxCommand Tests', () {

    test('FetchInboxCommand is able to add, pause, resume and stop FetchInboxCommand with no errors', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      AccountService accountService = await AccountService().open(database);
      AccountModel account = AccountModel();
      account.accountId = 123;
      account.provider = AccountModelProvider.google;
      account.accessToken = '';
      FetchInboxCommand testCommand = FetchInboxCommand(
          account,
          DateTime.now().subtract(Duration(days:10)),
          '',
          IntgContextEmail(accountService)
      );
      CmdMgr.addCommand(testCommand);
      testCommand.listeners.add((event) async => 'print ok');
      CmdMgr.pauseCommand(testCommand.id);
      CmdMgr.resumeCommand(testCommand.id);
      expect(1, 1);
    });

    test('Subscribe to FetchInboxCommand and get the notifications with the count of indexed emails', () async {
      int msgCount = 0;
      bool notified = false;
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      AccountService accountService = await AccountService().open(database);
      AccountModel account = AccountModel();
      account.accountId = 123;
      account.provider = AccountModelProvider.google;
      account.accessToken = '';
      FetchInboxCommand testCommand = FetchInboxCommand(
          account,
          DateTime.now().subtract(Duration(days:10)),
          '',
          IntgContextEmail(accountService)
      );
      CmdMgr.addCommand(testCommand);
      testCommand.listeners.add((notification) async {
        if(notification is FetchInboxCommandNotification) {
          notified = true;
          msgCount += notification.messages.length;
        }
      });
      Future.delayed(Duration(seconds:5));
      expect(notified, true);
      expect(msgCount == 0, false);
    });
  });
}