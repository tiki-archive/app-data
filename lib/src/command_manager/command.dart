import 'package:flutter/foundation.dart';

import 'command_manager_service.dart';
import 'model/command_status.dart';

abstract class Command{
  late final CommandManagerService _managerService;
  CommandStatus _status = CommandStatus.idle;

  CommandStatus get status => _status;
  set status(CommandStatus value){
    notify();
    _status = value;
  }

  @nonVirtual
  void addManager(CommandManagerService manager){
    _managerService = manager;
  }

  @nonVirtual
  void start(){
    status = CommandStatus.running;
    onStart();
  }

  @nonVirtual
  void pause(){
    status = CommandStatus.paused;
    onPause();
  }

  @nonVirtual
  void resumme(){
    status = CommandStatus.running;
    onResume();
  }

  @nonVirtual
  void stop(){
    status = CommandStatus.idle;
    onStop();
  }

  @nonVirtual
  void notify(){
    _managerService.notify(this);
  }

  @nonVirtual
  void finish(){
    _managerService.finishCommand(this);
    notify();
  }

  Function onStart();
  Function onStop();
  Function onPause();
  Function onResume();

}