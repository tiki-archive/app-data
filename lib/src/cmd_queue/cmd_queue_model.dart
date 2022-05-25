import 'dart:collection';

import 'cmd_queue_command.dart';
import 'cmd_queue_command_event.dart';
import 'cmd_queue_model_queue_status.dart';
class CmdQueueModel{
  final int activeLimit;
  final ListQueue<CmdQueueCommand> commandQueue = ListQueue<CmdQueueCommand>();

  Map<String, DateTime> lastRun = {};

  int activeCommands = 0;
  CmdQueueModelQueueStatus status = CmdQueueModelQueueStatus.idle;

  CmdQueueModel({this.activeLimit = 5});

}