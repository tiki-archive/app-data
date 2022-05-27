import 'dart:async';

import 'package:logging/logging.dart';

import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command.dart';
import '../cmd_mgr/cmd_mgr_notification_finish.dart';
import '../intg/intg_context_email.dart';
import 'fetch_inbox_cmd_notification.dart';
import 'fetch_inbox_cmd_notification_finish.dart';

class FetchInboxCmd extends CmdMgrCommand{
  final Logger _log = Logger('FetchInboxCommand');
  final AccountModel _account;
  final DateTime? _since;
  final String? _page;
  final IntgContextEmail _intgContextEmail;

  FetchInboxCmd(this._account, this._since, this._page, this._intgContextEmail);

  Future<void> index() async {
    _log.fine(
        'email index ${_account.email} on ${DateTime.now().toIso8601String()}');
      _intgContextEmail.getInbox(
          account: _account,
          since: _since,
          onResult: (messages) async {
            notify(FetchInboxCmdNotification(_account, messages));
            _log.fine('indexed ${messages.length} messages');
          },
          onFinish: () async {
            notify(CmdMgrNotificationFinish(id));
            _log.fine('finished email index for ${_account.email}.');
          });
  }

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
  Future<void> onStart() async{
    index();
  }

  @override
  Future<void> onStop() async {
    notify(FetchInboxCmdNotificationFinish(_account));
  }

  static String generateId(AccountModel account) =>
      'FetchInboxCommand_${account.accountId!}_${account.provider!}';
}