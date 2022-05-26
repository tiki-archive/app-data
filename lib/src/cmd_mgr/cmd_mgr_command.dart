import 'cmd_mgr_command_notification.dart';
import 'cmd_mgr_command_status.dart';

abstract class CmdMgrCommand{

  Duration get minRunFreq;
  String get id;
  CmdMgrCommandStatus status = CmdMgrCommandStatus.waiting;
  List<Future<void> Function(CmdMgrCommandNotification)> listeners = [];

  void notify(CmdMgrCommandNotification notification) {
    for(Future Function(CmdMgrCommandNotification) listener in listeners){
      listener(notification);
    }
  }

  Future<void> onStart();
  Future<void> onPause();
  Future<void> onResume();
  Future<void> onStop();

}