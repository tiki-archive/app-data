import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'cmd_queue_command.dart';
import 'cmd_queue_command_event.dart';
import 'cmd_queue_command_notification.dart';
import 'cmd_queue_model_queue_status.dart';
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
    command.listeners.add(_eventsListener);
    _model.commandQueue.add(command);
    _log.finest('Command with id ${command.id} enqueued.');
    _log.finest('Queue has ${_model.commandQueue.length} commands.' );
    _runQueue();
    return true;
  }

  List<CmdQueueCommand> getAll() => _model.commandQueue.toList();

  CmdQueueCommand? getCommandById(String id) {
    try {
      return _model.commandQueue.firstWhere((cmd) => cmd.id == id);
    }catch(e){
      _log.warning('Command with id $id not found.');
      return null;
    }
  }

  void _runQueue(){
    if(_isQueueRunning()) return;
    _model.status = CmdQueueModelQueueStatus.running;
    _runCommands();
  }

  void _runCommands({List<CmdQueueCommand> ignore = const []}) {
    _model.commandQueue.removeWhere((command) => command.status == CmdQueueCommandStatus.stopped);
    if(_isQueueEmpty()) return;
    if(_isQueueRunningAll()) return;
    for(CmdQueueCommand command in _model.commandQueue){
      if(_isRunningQueueFull()) break;
      if(ignore.contains(command) || !_canRun(command)) continue;
      command.start();
    }
  }

  bool _isQueueRunning() => _model.status == CmdQueueModelQueueStatus.running;

  bool _isRunningQueueFull() {
    if(_model.activeCommands >= _model.activeLimit){
      _log.finest('Queue has ${_model.activeCommands} commands and the limit is ${_model.activeLimit}');
      return true;
    }
    return false;
  }

  bool _canRun(CmdQueueCommand command) {
    if(command.status != CmdQueueCommandStatus.waiting) return false;
    if(_model.lastRun[command.id] != null && _model.lastRun[command.id]!
            .add(command.minRunFreq).isAfter(DateTime.now())) return false;
    return true;
  }

  bool _isQueueEmpty() {
    if(_model.commandQueue.length == 0){
      _log.finest('Queue is empty.' );
      _model.status = CmdQueueModelQueueStatus.idle;
      return true;
    }
    return false;
  }

  bool _isQueueRunningAll() {
    if(_model.commandQueue.length == _model.activeCommands){
      _log.finest('All items are running.' );
      return true;
    }
    return false;
  }

  Future<void> _eventsListener(CmdQueueCommandNotification notification, CmdQueueCommand command) async{
    if(!(notification is CmdQueueCommandEvent)) return;
    switch(notification.event){
      case CmdQueueCommandEventType.start:
      case CmdQueueCommandEventType.resume:
        _model.activeCommands++;
        break;
      case CmdQueueCommandEventType.pause:
        _model.activeCommands--;
        _runCommands();
        break;
      case CmdQueueCommandEventType.stop:
        _model.commandQueue.remove(command);
        _model.activeCommands--;
        break;
    }
    _log.finest('Queue has ${_model.activeCommands} commands.' );
  }

}