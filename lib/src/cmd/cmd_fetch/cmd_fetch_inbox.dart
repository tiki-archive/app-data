import 'dart:async';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../account/account_service.dart';
import '../../email/msg/email_msg_model.dart';
import '../../fetch/fetch_model_part.dart';
import '../../fetch/fetch_model_status.dart';
import '../../fetch/fetch_service.dart';
import '../../intg/intg_context_email.dart';
import '../cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_exception.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import 'cmd_fetch_inbox_notification.dart';

class CmdFetchInbox extends CmdMgrCmd{
  final Logger _log = Logger('FetchInboxCommand');
  final AccountModel _account;
  final DateTime? _since;
  String? _page;

  num _amountIndexed = 0;
  num _amountToIndex = 1;

  final IntgContextEmail _intgContextEmail;
  final FetchService _fetchService;

  Amplitude? _amplitude;

  CmdFetchInbox(
      FetchService this._fetchService,
      AccountModel this._account,
      DateTime? this._since,
      String? this._page,
      AccountService accountService,
      Httpp? httpp,
      Amplitude? amplitude
    ) :
      _amplitude = amplitude,
      _intgContextEmail = IntgContextEmail(accountService, httpp: httpp);

  Future<void> index() async {

    if (this._since == null) {
      // We're re-indexing from scratch, so we wipe the old status/fetch record
      await _fetchService.saveStatus(_account, amount_indexed: 0, amount_fetched: 0, total: 0);

    }

    await _intgContextEmail.countInbox(
        account: _account,
        since: _since,
        onResult: (amount) {
          _fetchService.saveStatus(_account, total: amount);

          _amountIndexed = 0;
          _amountToIndex = amount;
        },
        onFinish: () => {});

    _log.fine('email index ${_account.email} on ${DateTime.now().toIso8601String()}');
    if(_page != null) _log.info('email index started in page:$_page');
    try {
      _intgContextEmail.getInbox(
          account: _account,
          since: _since,
          page: _page,
          onResult: _saveParts,
          onFinish: _onFinish
      );
    }catch(e){
      CmdMgrCmdNotifException(e.toString(),exception: e);
    }
  }

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    if(_page != null) {
      await _fetchService.savePage(_page!, _account);
    }
  }

  @override
  Future<void> onResume() async {
    _page = await _fetchService.getPage(_account);
    index();
  }

  @override
  Future<void> onStart() async{
    index();
  }

  @override
  Future<void> onStop() async {
    if(_page != null) {
      await _fetchService.savePage(_page!, _account);
    }
  }

  static String generateId(AccountModel account) {
    int id = account.accountId!;
    String prov = account.emailApi!.value;
    return "CmdFetchInbox.$prov.$id";
  }

  Future<void> _saveParts(List<EmailMsgModel> messages, {String? page}) async {

      List<FetchModelPart<EmailMsgModel>> parts = messages.map((message) =>
          FetchModelPart(
              extId: message.extMessageId,
              account: _account,
              api: _account.emailApi,
              obj: message))
          .toList();
      await _fetchService.saveParts(parts, _account);
      _page = page;
      if(_page != null) await _fetchService.savePage(_page!, _account);

      // add the amount indexed
      _amountIndexed += parts.length;

      if(_page !=null) await _fetchService.savePage(_page!, _account);
      if(_amplitude != null){
        _amplitude!.logEvent("EMAILS_INDEXED", eventProperties: {
          "count" : parts.length
        });
        _amplitude!.logEvent("EMAIL_MSG_INDEXED");
      }

      notify(CmdFetchInboxNotification(_account, messages));
      _log.fine('indexed ${messages.length} messages');

      _fetchService.incrementStatus(_account, amount_indexed_change: messages.length);
  }

  Future<void> _onFinish() async {
      _log.fine('finished email index for ${_account.email}.');

      // in case the email provider count is higher than
      // the amount it returns indexing, we still want these
      // two values to end up the same.
      _amountToIndex = _amountIndexed;

      if(_page !=null) await _fetchService.savePage(_page!, _account);
      notify(CmdMgrCmdNotifFinish(id));
  }

  @override
  num getProgress() {
    return _amountIndexed / _amountToIndex;
  }

  @override
  String getProgressDescription() {
    return "${_amountIndexed}/${_amountToIndex} emails indexed";
  }

}