import 'cmd_queue_command_notification.dart';
import 'cmd_queue_command_status.dart';

abstract class CmdQueueCommand{

  Duration get minRunFreq;
  String get id;
  CmdQueueCommandStatus status = CmdQueueCommandStatus.waiting;
  List<Future<void> Function(CmdQueueCommandNotification)> listeners = [];

  void notify(CmdQueueCommandNotification notification) {
    for(Future Function(CmdQueueCommandNotification) listener in listeners){
      listener(notification);
    }
  }

  Future<void> onStart();
  Future<void> onPause();
  Future<void> onResume();
  Future<void> onStop();

}