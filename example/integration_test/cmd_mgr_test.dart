/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/cmd_mgr/command.dart';
import 'package:tiki_data/src/cmd_mgr/model/command_status.dart';
import 'package:tiki_data/src/cmd_mgr/cmd_mgr_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Command Manager Tests', () {

    test('Run command in queue', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService cmdMgr = CmdMgrService(database);
      TestCommand testCommand = TestCommand();
      cmdMgr.addCommand(testCommand);
      cmdMgr.subscribe(TestCommand, (data) => 'print $data');
      cmdMgr.pauseCommand(testCommand);
      cmdMgr.resumeCommand(testCommand);
      expect(1, 1);
    });

    test('Subscribe to command in queue', () async {
      bool receivedData = false;
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdMgrService cmdMgr = CmdMgrService(database);
      TestCommand testCommand = TestCommand();
      cmdMgr.addCommand(testCommand);
      cmdMgr.subscribe(TestCommand, (data) {
        receivedData = true;
      });
      cmdMgr.pauseCommand(testCommand);
      cmdMgr.resumeCommand(testCommand);
      await Future.delayed(Duration(seconds:20));
      expect(receivedData, true);
    });

  });
}

class TestCommand extends Command{
  int count = 10;

  @override
  Future<Function()> onEnqueue() async {
    return () => print('enqueued');
  }

  @override
  Future<Function()> onPause() async {
    return () => print('paused');
  }

  @override
  Future<Function()> onResume() async {
    return () => print('resumed');
  }

  @override
  Future<Function()> onStart() async {
    _doSomething(time: 2);
    return () => print('started');
  }

  @override
  Future<Function()> onStop() async {
    return () => print('stopped');
  }

  Future<void> _doSomething({required int time}) async {
    if(this.status == CommandStatus.running) {
      notify();
      await(Future.delayed(Duration(seconds: time)));
      if(count > 0){
        count--;
        _doSomething(time: time);
      }else{
        finish();
      }
    }
  }

}