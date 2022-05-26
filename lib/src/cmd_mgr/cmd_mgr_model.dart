import 'dart:collection';
import 'cmd_mgr_command.dart';

class CmdMgrModel{
  final int activeLimit;
  final ListQueue<CmdMgrCommand> commandQueue = ListQueue<CmdMgrCommand>();

  Map<String, DateTime> lastRun = {};
  int activeCommands = 0;

  CmdMgrModel({this.activeLimit = 5});

}