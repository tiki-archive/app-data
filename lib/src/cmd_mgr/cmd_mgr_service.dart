import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'cmd_mgr_command.dart';
import 'cmd_mgr_repository.dart';
import 'cmd_mgr_model.dart';
import 'cmd_mgr_command_status.dart';

class CmdMgrService{

  Logger _log = Logger('CmdMgrService');

  final CmdMgrRepository _repository;
  CmdMgrModel _model = CmdMgrModel();

  CmdMgrService(Database database) :
      _repository = CmdMgrRepository(database){
  }

  Future<void> init() async {
    _model.lastRun = await _repository.getAllLastRun();
  }

  bool addCommand(CmdMgrCommand command){
    if(_model.commandQueue.where((element) => element.id == command.id).isNotEmpty) {
      _log.warning('Command with id ${command.id} already enqueued.');
      return false;
    }
    _model.commandQueue.add(command);
    _log.finest('Command with id ${command.id} enqueued.');
    _log.finest('Queue has ${_model.commandQueue.length} commands.' );
    _runCommands();
    return true;
  }

  void resumeCommand(String id){
    CmdMgrCommand? command = getById(id);
    if(command?.status == CmdMgrCommandStatus.paused){
      command!.status = CmdMgrCommandStatus.waiting;
      command.onResume();
      _runCommands();
    }
  }

  void stopCommand(String id){
    CmdMgrCommand? command = getById(id);
    if(command?.status == CmdMgrCommandStatus.running){
      command!.status = CmdMgrCommandStatus.stopped;
      command.onStop();
      _model.commandQueue.remove(command);
      _model.activeCommands--;
      _runCommands();
    }
  }

  void pauseCommand(String id){
    CmdMgrCommand? command = getById(id);
    if(command?.status == CmdMgrCommandStatus.running){
      command!.status = CmdMgrCommandStatus.paused;
      _model.activeCommands--;
      command.onPause();
      _runCommands();
    }
  }

  List<CmdMgrCommand> getAll() => _model.commandQueue.toList();

  void _runCommands() {
    int limit = _model.activeLimit - _model.activeCommands;
    for(int i = 0; i < limit; i++){
      try {
        CmdMgrCommand command = _model.commandQueue.firstWhere((cmd) =>
            _canRun(cmd));
        command.status = CmdMgrCommandStatus.running;
        _model.activeCommands++;
        command.onStart();
      }catch(e){
        _log.fine('no runnable commands');
        break;
      }
    }
  }

  bool _canRun(CmdMgrCommand command) {
      if(command.status != CmdMgrCommandStatus.waiting) return false;
      if(_model.lastRun[command.id] != null && _model.lastRun[command.id]!
          .add(command.minRunFreq).isAfter(DateTime.now())) return false;
      return true;
  }

  CmdMgrCommand? getById(String id){
    try{
     return _model.commandQueue.firstWhere((element) => element.id == id);
    }catch(e){
      _log.finest('Command not found');
      return null;
    }
  }

}