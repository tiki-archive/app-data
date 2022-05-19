import 'dart:collection';

import 'command.dart';

class CommandManagerModel{
  final ListQueue<Command> _commandQueue = ListQueue<Command>();
  static final int _activeLimit = 5;
  static final int _activeCommands = 0;
  Map<Type, List<Function>> listeners = {};
  DateTime? lastRun;
}