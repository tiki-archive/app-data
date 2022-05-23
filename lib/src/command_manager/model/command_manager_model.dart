import 'dart:collection';

import '../command.dart';
import 'command_manager_queue_status.dart';

class CommandManagerModel{
  final int activeLimit;
  final ListQueue<Command> commandQueue = ListQueue<Command>();
  final Map<Type, List<Future Function(Command command)>> listeners = {};
  Map<String, DateTime> lastRun = {};

  int activeCommands = 0;
  CommandManagerQueueStatus status = CommandManagerQueueStatus.idle;

  CommandManagerModel({this.activeLimit = 5});

}