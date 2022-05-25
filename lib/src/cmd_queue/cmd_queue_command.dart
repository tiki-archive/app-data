import 'cmd_queue_command_event.dart';
import 'cmd_queue_command_notification.dart';
import 'cmd_queue_command_status.dart';

abstract class CmdQueueCommand{

  Duration get minRunFreq;
  String get id;
  bool _started = false;

  CmdQueueCommandStatus _status = CmdQueueCommandStatus.waiting;
  CmdQueueCommandStatus get status => _status;

  List<Future<void> Function(CmdQueueCommandNotification, CmdQueueCommand)> listeners = [];

  void notify(CmdQueueCommandNotification notification) {
    for(Future Function(CmdQueueCommandNotification, CmdQueueCommand) listener in listeners){
      listener(notification, this);
    }
  }

  void start(){
    _status = CmdQueueCommandStatus.running;
    if(!_started) {
      _onStart();
      notify(CmdQueueCommandEvent.start());
    }else{
      _onResume();
      notify(CmdQueueCommandEvent.resume());
    }
  }

  void pause(){
    _status = CmdQueueCommandStatus.paused;
    _onPause();
    notify(CmdQueueCommandEvent.pause());
  }

  void resume(){
    _status = CmdQueueCommandStatus.waiting;
  }

  void stop(){
    _status = CmdQueueCommandStatus.running;
    _onStop();
    notify(CmdQueueCommandEvent.stop());
  }

  Future<void> _onStart();
  Future<void> _onPause();
  Future<void> _onResume();
  Future<void> _onStop();

}