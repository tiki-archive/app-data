import 'package:flutter/foundation.dart';

import 'command_manager_service.dart';
import 'model/command_status.dart';

abstract class Command{
  late final CommandManagerService _managerService;
  CommandStatus _status = CommandStatus.idle;
  Duration minRunInterval = Duration.zero;

  CommandStatus get status => _status;
  set status(CommandStatus value){
    notify();
    _status = value;
  }

  @nonVirtual
  void addManager(CommandManagerService manager) async {
    _managerService = manager;
  }

  @nonVirtual
  Future<void> enqueue()  async {
    status = CommandStatus.enqueued;
    onEnqueue();
    notify();
  }

  @nonVirtual
  Future<void> start() async {
    status = CommandStatus.running;
    onStart();
  }

  @nonVirtual
  Future<void> pause() async {
    status = CommandStatus.idle;
    onPause();
  }

  @nonVirtual
  Future<void> stop() async {
    status = CommandStatus.idle;
    onStop();
  }

  @nonVirtual
  Future<void> finish() async {
    _managerService.finishCommand(this);
    notify();
  }

  @nonVirtual
  void notify(){
    _managerService.notify(this);
  }

  Future Function() onStart();
  Future Function() onStop();
  Future Function() onPause();
  Future Function() onResume();
  Future Function() onEnqueue();

}