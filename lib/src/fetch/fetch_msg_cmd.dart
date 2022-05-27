import 'dart:core';

import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command.dart';
import '../cmd_mgr/cmd_mgr_notification_finish.dart';
import '../email/msg/email_msg_model.dart';
import '../intg/intg_context_email.dart';
import 'fetch_msg_cmd_notification.dart';
import 'fetch_part_model.dart';

class FetchMsgCmd extends CmdMgrCommand {

  final AccountModel _account;
  final List<FetchPartModel> _parts;
  final IntgContextEmail _intgContextEmail;
  final List<EmailMsgModel> _save = [];
  final List<EmailMsgModel> _fetch = [];
  final Function()? onFinish;

  FetchMsgCmd(
      List<FetchPartModel> this._parts,
      AccountModel this._account,
      IntgContextEmail this._intgContextEmail,
      {this.onFinish}
      );

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    // record where paused
    // stop fetching
  }

  @override
  Future<void> onResume() async {
    // get where paused
    // restart from there
  }

  @override
  Future<void> onStart() async {
    _processParts();
  }

  @override
  Future<void> onStop() async {
    notify(CmdMgrNotificationFinish(id));
  }

  static String generateId(AccountModel account) =>
      'FetchInboxCommand_${account.accountId!}_${account.provider!}';

  Future<void> _processParts() async {
    List<String> ids = _parts
        .where((part) => part.obj?.extMessageId != null)
        .map((part) => part.obj!.extMessageId! as String)
        .toList();
    List<EmailMsgModel> fetched = List.empty(growable: true);
    List<EmailMsgModel> save = List.empty(growable: true);
    _intgContextEmail.getMessages(
        account: _account,
        messageIds: ids,
        onResult: (message) => (message) {
          if (message.toEmail == _account.email! &&
              message.sender?.unsubscribeMailTo != null) save.add(message);
          fetched.add(message);
          notify(FetchMsgCmdNotification(_account, _save, _fetch));
        },
        onFinish: () => onFinish != null ? onFinish!() : null
    );
  }
}
