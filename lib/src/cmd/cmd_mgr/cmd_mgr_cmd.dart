import 'cmd_mgr_cmd_notif.dart';
import 'cmd_mgr_cmd_status.dart';

abstract class CmdMgrCmd{

  Duration get minRunFreq;
  String get id;
  CmdMgrCmdStatus status = CmdMgrCmdStatus.waiting;
  List<Future<void> Function(CmdMgrCmdNotif)> listeners = [];

  void notify(CmdMgrCmdNotif notification) {
    for(Future Function(CmdMgrCmdNotif) listener in listeners){
      listener(notification);
    }
  }

  Future<void> onStart();
  Future<void> onPause();
  Future<void> onResume();
  Future<void> onStop();

}