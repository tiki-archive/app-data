import 'dart:collection';

import 'cmd_mgr_command.dart';
import 'cmd_mgr_model_queue_status.dart';
class CmdMgrModel{
  final int activeLimit;
  final ListQueue<CmdMgrCommand> commandQueue = ListQueue<CmdMgrCommand>();
  final Map<String, List<Function(CmdMgrCommand command)>> listeners = {};
  Map<String, DateTime> lastRun = {};

  int activeCommands = 0;
  CmdMgrModelQueueStatus status = CmdMgrModelQueueStatus.idle;

  CmdMgrModel({this.activeLimit = 5});

}