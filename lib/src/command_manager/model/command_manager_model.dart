import 'dart:collection';

import '../command.dart';

class CommandManagerModel{
  static final int activeLimit = 5;
  final ListQueue<Command> commandQueue = ListQueue<Command>();

  int activeCommands = 0;
  Map<Type, List<Function>> listeners = {};
  DateTime? lastRun;

  CommandManagerModel.fromMap(Map<String, Object?> map):
    lastRun = map['last_run'] != null ? DateTime.parse(map['last_run'].toString()) : null;

  Map<String, Object?> toMap() {
    return {
      "last_run" : lastRun?.toIso8601String()
    };
  }

}