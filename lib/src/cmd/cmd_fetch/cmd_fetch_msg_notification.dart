import '../../account/account_model.dart';
import '../../email/msg/email_msg_model.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif.dart';

class CmdFetchMsgNotification extends CmdMgrCmdNotif{
  final AccountModel account;
  final List<EmailMsgModel> fetch;
  final List<EmailMsgModel> save;
  final int total;

  CmdFetchMsgNotification(this.account, this.save, this.fetch, this.total);
}