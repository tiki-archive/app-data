import 'dart:collection';

import '../command.dart';
import 'cmd_mgr_queue_status.dart';

class CmdMgrModel{
  final int activeLimit;
  final ListQueue<Command> commandQueue = ListQueue<Command>();
  final Map<Type, List<Function(Command command)>> listeners = {};
  Map<String, DateTime> lastRun = {};

  int activeCommands = 0;
  CmdMgrQueueStatus status = CmdMgrQueueStatus.idle;

  CmdMgrModel({this.activeLimit = 5});

}