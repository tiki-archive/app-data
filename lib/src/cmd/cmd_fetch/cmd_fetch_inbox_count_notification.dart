import '../../account/account_model.dart';
import '../../email/msg/email_msg_model.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif.dart';

class CmdFetchInboxCountNotification extends CmdMgrCmdNotif{
  final AccountModel account;
  final int totalEmails;

  CmdFetchInboxCountNotification(this.account, this.totalEmails);
}