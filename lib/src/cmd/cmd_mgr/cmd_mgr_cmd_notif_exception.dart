import 'cmd_mgr_cmd_notif.dart';

class CmdMgrCmdNotifException extends CmdMgrCmdNotif{
  final String commandId;
  final Object? exception;

  CmdMgrCmdNotifException(this.commandId, {Object? this.exception});
}