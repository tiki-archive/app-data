import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'cmd_queue_command.dart';
import 'cmd_queue_repository.dart';
import 'cmd_queue_model.dart';
import 'cmd_queue_command_status.dart';

class CmdQueueService{

  Logger _log = Logger('CmdQueueService');

  final CmdQueueRepository _repository;
  CmdQueueModel _model = CmdQueueModel();

  CmdQueueService(Database database) :
      _repository = CmdQueueRepository(database){
  }

  Future<void> init() async {
    _model.lastRun = await _repository.getAllLastRun();
  }

  bool addCommand(CmdQueueCommand command){
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
    CmdQueueCommand? command = getById(id);
    if(command?.status == CmdQueueCommandStatus.paused){
      command!.status = CmdQueueCommandStatus.waiting;
      command.onResume();
      _runCommands();
    }
  }

  void stopCommand(String id){
    CmdQueueCommand? command = getById(id);
    if(command?.status == CmdQueueCommandStatus.running){
      command!.status = CmdQueueCommandStatus.stopped;
      command.onStop();
      _model.commandQueue.remove(command);
      _model.activeCommands--;
      _runCommands();
    }
  }

  void pauseCommand(String id){
    CmdQueueCommand? command = getById(id);
    if(command?.status == CmdQueueCommandStatus.running){
      command!.status = CmdQueueCommandStatus.paused;
      _model.activeCommands--;
      command.onPause();
      _runCommands();
    }
  }

  List<CmdQueueCommand> getAll() => _model.commandQueue.toList();

  void _runCommands() {
    int limit = _model.activeLimit - _model.activeCommands;
    for(int i = 0; i < limit; i++){
      try {
        CmdQueueCommand command = _model.commandQueue.firstWhere((cmd) =>
            _canRun(cmd));
        command.status = CmdQueueCommandStatus.running;
        _model.activeCommands++;
        command.onStart();
      }catch(e){
        _log.fine('no runnable commands');
        break;
      }
    }
  }

  bool _canRun(CmdQueueCommand command) {
      if(command.status != CmdQueueCommandStatus.waiting) return false;
      if(_model.lastRun[command.id] != null && _model.lastRun[command.id]!
          .add(command.minRunFreq).isAfter(DateTime.now())) return false;
      return true;
  }

  CmdQueueCommand? getById(String id){
    try{
     return _model.commandQueue.firstWhere((element) => element.id == id);
    }catch(e){
      _log.finest('Command not found');
      return null;
    }
  }

}