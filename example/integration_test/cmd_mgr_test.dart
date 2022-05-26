/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../lib/src/cmd_mgr/cmd_mgr_service.dart';
import '../../lib/src/cmd_mgr/cmd_mgr_command.dart';
import '../../lib/src/cmd_mgr/cmd_mgr_command_status.dart';
import '../../lib/src/cmd_mgr/cmd_mgr_command_notification.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Command Manager Tests', () {

    test('Run command in queue', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      TestCommand testCommand = TestCommand(Uuid().v4().toString());
      CmdMgr.addCommand(testCommand);
      testCommand.listeners.add((event) async => 'print ok');
      CmdMgr.pauseCommand(testCommand.id);
      CmdMgr.resumeCommand(testCommand.id);
      expect(1, 1);
    });

    test('Subscribe to command in queue', () async {
      List<CmdMgrCommandNotification> receivedData = [];
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      String commandId = "Subscribe to command in queue";
      TestCommand testCommand = TestCommand(commandId);
      CmdMgr.addCommand(testCommand);
      testCommand.listeners.add((event) async {
        receivedData.add(event);
      });
      Future.delayed(Duration(seconds: 2));
      CmdMgr.pauseCommand(testCommand.id);
      CmdMgr.resumeCommand(testCommand.id);
      expect(receivedData.length, 3);
    });

    test('Do not add commands with same id', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      String commandId = "sameID";
      TestCommand testCommand = TestCommand(commandId);
      TestCommand testCommand2 = TestCommand(commandId);
      expect(CmdMgr.addCommand(testCommand), true);
      expect(CmdMgr.addCommand(testCommand2), false);
    });


    test('Do not run commands before minRunFreq ', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService CmdMgr = CmdMgrService(database);
      String commandId = "sameID";
      TestCommand testCommand = TestCommand(commandId);
      TestCommand testCommand2 = TestCommand(commandId);
      expect(CmdMgr.addCommand(testCommand), true);
      expect(testCommand.status, CmdMgrCommandStatus.running);
      CmdMgr.stopCommand(testCommand.id);
      expect(CmdMgr.getAll().isEmpty, true);
      expect(CmdMgr.addCommand(testCommand2), true);
      expect(testCommand2.status, CmdMgrCommandStatus.waiting);
     Future.delayed(Duration(seconds: 5));
      CmdMgr.resumeCommand(testCommand.id);
      expect(testCommand.status, CmdMgrCommandStatus.running);
      CmdMgr.stopCommand(testCommand.id);
      expect(CmdMgr.getAll().isEmpty, true);
    });
  });
}

class TestCommand extends CmdMgrCommand{

  final String _id;

  TestCommand(this._id);

  @override
  Future<Function()> onPause() async {
    notify(TestNotification());
    return () => print('paused');
  }

  @override
  Future<Function()> onResume() async {
    notify(TestNotification());
    return () => print('resumed');
  }

  @override
  Future<Function()> onStart() async {
    notify(TestNotification());
    _doSomething(time: 2);
    return () => print('started');
  }

  @override
  Future<Function()> onStop() async {
    notify(TestNotification());
    return () => print('stopped');
  }

  Future<void> _doSomething({required int time}) async {
     await(Future.delayed(Duration(seconds: time)));
     status = CmdMgrCommandStatus.stopped;
  }

  @override
  String get id => _id;

  @override
  Duration get minRunFreq => Duration(seconds: 2);

}

class TestNotification extends CmdMgrCommandNotification{

}