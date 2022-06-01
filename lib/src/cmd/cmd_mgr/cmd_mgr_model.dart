import 'dart:collection';
import 'cmd_mgr_cmd.dart';

class CmdMgrModel{
  final int activeLimit;
  final ListQueue<CmdMgrCmd> commandQueue = ListQueue<CmdMgrCmd>();

  Map<String, DateTime> lastRun = {};
  int activeCommands = 0;

  CmdMgrModel({this.activeLimit = 5});

}