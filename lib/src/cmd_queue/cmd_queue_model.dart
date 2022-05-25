import 'dart:collection';
import 'cmd_queue_command.dart';

class CmdQueueModel{
  final int activeLimit;
  final ListQueue<CmdQueueCommand> commandQueue = ListQueue<CmdQueueCommand>();

  Map<String, DateTime> lastRun = {};
  int activeCommands = 0;

  CmdQueueModel({this.activeLimit = 5});

}