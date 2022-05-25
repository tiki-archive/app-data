/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/cmd_mgr/cmd_queue_command.dart';
import 'package:tiki_data/src/cmd_mgr/cmd_queue_command_status.dart';
import 'package:tiki_data/src/cmd_mgr/cmd_queue_command_event.dart';
import 'package:tiki_data/src/cmd_mgr/cmd_queue_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Command Manager Tests', () {

    test('Run command in queue', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdQueueService CmdQueue = CmdQueueService(database);
      TestCommand testCommand = TestCommand(Uuid().v4().toString());
      CmdQueue.addCommand(testCommand);
      CmdQueue.subscribe(testCommand.id, (command, event) async => 'print $command');
      CmdQueue.pauseCommand(testCommand);
      CmdQueue.resumeCommand(testCommand);
      expect(1, 1);
    });

    test('Subscribe to command in queue', () async {
      List<CmdQueueCommandEvent> receivedData = [];
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdQueueService CmdQueue = CmdQueueService(database);
      String commandId = "Subscribe to command in queue";
      TestCommand testCommand = TestCommand(commandId);
      CmdQueue.addCommand(testCommand);
      CmdQueue.subscribe(testCommand.id,  (command, event) async {
        receivedData.add(event);
      });
      Future.delayed(Duration(seconds: 2));
      CmdQueue.pauseCommand(testCommand);
      CmdQueue.resumeCommand(testCommand);
      expect(receivedData.length, 3);
      expect(receivedData.contains(CmdQueueCommandEvent.start), true);
      expect(receivedData.contains(CmdQueueCommandEvent.pause), true);
      expect(receivedData.contains(CmdQueueCommandEvent.resume), true);
    });

    test('Do not add commands with same id', () async {
      List<CmdQueueCommandEvent> receivedData = [];
      Database database = await openDatabase('${Uuid().v4()}.db');
      CmdQueueService CmdQueue = CmdQueueService(database);
      String commandId = "sameID";
      TestCommand testCommand = TestCommand(commandId);
      TestCommand testCommand2 = TestCommand(commandId);
      expect(CmdQueue.addCommand(testCommand), true);
      expect(CmdQueue.addCommand(testCommand2), false);
    });

  });
}

class TestCommand extends CmdQueueCommand{

  final String _id;

  TestCommand(this._id);

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
    _doSomething(time: 1);
    return () => print('started');
  }

  @override
  Future<Function()> onStop() async {
    return () => print('stopped');
  }

  Future<void> _doSomething({required int time}) async {
     await(Future.delayed(Duration(seconds: time)));
     status = CmdQueueCommandStatus.stopped;
  }

  @override
  String get id => _id;

  @override
  Duration get minRunFreq => Duration.zero;

}