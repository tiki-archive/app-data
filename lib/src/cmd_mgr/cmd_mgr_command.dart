import 'package:flutter/foundation.dart';

import 'cmd_mgr_command_status.dart';

abstract class CmdMgrCommand{

  @nonVirtual
  CmdMgrCommandStatus _status = CmdMgrCommandStatus.waiting;
  @nonVirtual
  CmdMgrCommandStatus get status => _status;
  @nonVirtual
  set status(CmdMgrCommandStatus newValue){
    switch(newValue){
      case CmdMgrCommandStatus.running:
        if(_started) {
          onResume();
        }else{
          onStart();
          _started = true;
        }
        break;
      case CmdMgrCommandStatus.paused:
        onPause();
        break;
      case CmdMgrCommandStatus.stopped:
        onStop();
        break;
      case CmdMgrCommandStatus.waiting:
        break;
    }
    _status = newValue;
  }

  bool _started = false;
  Duration get minRunFreq;
  String get id;

  Future<void> onStart();
  Future<void> onPause();
  Future<void> onResume();
  Future<void> onStop();

}
