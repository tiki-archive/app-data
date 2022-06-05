import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'cmd_mgr_cmd.dart';
import 'cmd_mgr_cmd_notif.dart';
import 'cmd_mgr_cmd_notif_exception.dart';
import 'cmd_mgr_cmd_notif_finish.dart';
import 'cmd_mgr_last_run_repository.dart';
import 'cmd_mgr_model.dart';
import 'cmd_mgr_cmd_status.dart';

class CmdMgrService{

  Logger _log = Logger('CmdMgrService');

  final CmdMgrLastRunRepository _repositoryLastRun;
  CmdMgrModel _model = CmdMgrModel();

  CmdMgrService(Database database) :
      _repositoryLastRun = CmdMgrLastRunRepository(database){
  }

  Future<CmdMgrService> init() async {
    await _repositoryLastRun.createTable();
    _model.lastRun = await _repositoryLastRun.getAllLastRun();
    return this;
  }

  bool addCommand(CmdMgrCmd command){
    if(_model.commandQueue.where((element) => element.id == command.id).isNotEmpty) {
      _log.warning('Command with id ${command.id} already enqueued.');
      return false;
    }
    _model.commandQueue.add(command);
    command.listeners.add(_commmandsListener);
    _log.finest('Command with id ${command.id} enqueued.');
    _log.finest('Queue has ${_model.commandQueue.length} commands.' );
    _runCommands();
    return true;
  }

  void resumeCommand(String id){
    CmdMgrCmd? command = getById(id);
    if(command?.status == CmdMgrCmdStatus.paused){
      command!.status = CmdMgrCmdStatus.waiting;
      command.onResume();
      _runCommands();
    }
  }

  void stopCommand(String id){
    CmdMgrCmd? command = getById(id);
    if(command?.status == CmdMgrCmdStatus.running){
      command!.status = CmdMgrCmdStatus.stopped;
      command.onStop();
      _model.commandQueue.remove(command);
      _model.activeCommands--;
      _runCommands();
    }
  }

  void pauseCommand(String id){
    CmdMgrCmd? command = getById(id);
    if(command?.status == CmdMgrCmdStatus.running){
      command!.status = CmdMgrCmdStatus.paused;
      _model.activeCommands--;
      command.onPause();
      _runCommands();
    }
  }

  List<CmdMgrCmd> getAll() => _model.commandQueue.toList();

  DateTime? getLastRun(String id) => _model.lastRun[id];

  void _runCommands() {
    int limit = _model.activeLimit - _model.activeCommands;
    for(int i = 0; i < limit; i++){
      try {
        CmdMgrCmd command = _model.commandQueue.firstWhere((cmd) =>
            _canRun(cmd));
        command.status = CmdMgrCmdStatus.running;
        _model.activeCommands++;
        command.onStart();
      }catch(e){
        _log.fine('no runnable commands');
        break;
      }
    }
  }

  bool _canRun(CmdMgrCmd command) {
      if(command.status != CmdMgrCmdStatus.waiting) return false;
      if(_model.lastRun[command.id] != null && _model.lastRun[command.id]!
          .add(command.minRunFreq).isAfter(DateTime.now())) return false;
      return true;
  }

  CmdMgrCmd? getById(String id){
    try{
     return _model.commandQueue.firstWhere((element) => element.id == id);
    }catch(e){
      _log.finest('Command not found');
      return null;
    }
  }

  Future<void> _commmandsListener(CmdMgrCmdNotif notif) async {
    switch(notif.runtimeType){
      case CmdMgrCmdNotifFinish :
        String id = (notif as CmdMgrCmdNotifFinish).commandId;
        _log.finest('Received finish notification from $id');
        stopCommand(id);
        break;
      case CmdMgrCmdNotifException :
        String id = (notif as CmdMgrCmdNotifException).commandId;
        _log.finest('Received exception from $id: ${notif.exception.toString()} ');
        stopCommand(id);
        break;
    }
  }
}