import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command_notification.dart';
import '../email/msg/email_msg_model.dart';

class FetchMessagesCommandNotification extends CmdMgrCommandNotification{
  final AccountModel account;
  final List<EmailMsgModel> fetch;
  final List<EmailMsgModel> save;

  FetchMessagesCommandNotification(this.account, this.save, this.fetch);
}