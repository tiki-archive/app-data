import 'dart:core';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../account/account_service.dart';
import '../../company/company_service.dart';
import '../../decision/decision_strategy_spam.dart';
import '../../email/email_service.dart';
import '../../email/msg/email_msg_model.dart';
import '../../email/sender/email_sender_model.dart';
import '../../fetch/fetch_model_part.dart';
import '../../fetch/fetch_model_status.dart';
import '../../fetch/fetch_service.dart';
import '../../graph/graph_strategy_email.dart';
import '../../intg/intg_context_email.dart';
import '../cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_exception.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_progress_update.dart';
import '../cmd_mgr/cmd_mgr_cmd_status.dart';
import 'cmd_fetch_msg_notification.dart';

class CmdFetchMsg extends CmdMgrCmd {

  final Logger _log = Logger('CmdFetchMsg');
  final List<EmailMsgModel> _save = [];
  final List<EmailMsgModel> _fetched = [];

  num _amountFetched = 0;
  num _totalToFetch = 0;

  final FetchService _fetchService;
  final AccountModel _account;
  final DecisionStrategySpam _decisionStrategySpam;
  final GraphStrategyEmail _graphStrategyEmail;
  final EmailService _emailService;
  final CompanyService _companyService;
  final IntgContextEmail _intgContextEmail;

  Amplitude? _amplitude;

  CmdFetchMsg(
      AccountModel this._account,
      FetchService this._fetchService,
      AccountService accountService,
      EmailService this._emailService,
      CompanyService this._companyService,
      DecisionStrategySpam this._decisionStrategySpam,
      GraphStrategyEmail this._graphStrategyEmail,
      Httpp? httpp,
      Amplitude? this._amplitude
  ) : _intgContextEmail = IntgContextEmail(accountService, httpp: httpp);

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onStart() async {
    _totalToFetch = await _fetchService.countParts(_account);
    _getPartsAndFetchMsg();
  }

  @override
  Future<void> onPause() async {
    _processFetchedMessages();
  }

  @override
  Future<void> onResume() async {
    _totalToFetch = await _fetchService.countParts(_account);
    _getPartsAndFetchMsg();
  }

  @override
  Future<void> onStop() async {
    _processFetchedMessages();
  }

  static String generateId(AccountModel account) {
    int id = account.accountId!;
    String prov = account.emailApi!.value;
    return "CmdFetchMsg.$prov.$id";
  }

  Future<void> _getPartsAndFetchMsg() async {
    _totalToFetch = await _fetchService.countParts(_account);
    if(_totalToFetch == 0){
      _log.finest('${_account.email} - ${_account.provider} no parts to fetch. Finishing CmdFetchMsg');
      notify(CmdMgrCmdNotifFinish(id));
      return;
    }
    if (!await _intgContextEmail.isConnected(_account)) {
      _log.warning('${_account.email} - ${_account.provider} not connected. Finishing CmdFetchMsg');
      notify(CmdMgrCmdNotifFinish(id));
      return;
    }
    List<FetchModelPart> parts = await _fetchService.getParts(_account);
    _fetchMessages(parts);
  }

  Future<void> _fetchMessages(List<FetchModelPart> parts) async {
    List<String> ids = parts
        .where((part) => part.obj?.extMessageId != null)
        .map((part) => part.obj!.extMessageId! as String)
        .toList();
    try {
      _intgContextEmail.getMessages(
        account: _account,
        messageIds: ids,
        onResult: _onMessageFetched,
        onFinish: _processFetchedMessages,
      );
    }catch(e){
      notify(CmdMgrCmdNotifException(id, exception: e));
    }
  }

  void _onMessageFetched(EmailMsgModel message){
    if (message.toEmail?.toLowerCase() == _account.email!.toLowerCase() && message.sender?.unsubscribeMailTo != null) _save.add(message);

    _fetched.add(message);
    _log.fine('Fetched ${message.extMessageId}.');
    notify(CmdFetchMsgNotification(_account, _save, _fetched, _totalToFetch.toInt()));
  }

  Future<void> _processFetchedMessages() async {
    _log.fine('Fetched ${_fetched.length} processed messages');
    _log.fine('Proceeding to save ${_save.length} relevant messages');

    Map<String, EmailSenderModel> senders = {};
    _save.where((msg) => msg.sender != null && msg.sender?.email != null)
        .forEach((msg) => senders[msg.sender!.email!] = msg.sender!);
    await _saveSenders(senders);
    await _saveMessages(_save);
    await _saveCompanies(senders);

    await _fetchService.deleteParts(_fetched, _account);

    _amountFetched += _fetched.length;
    _fetchService.incrementStatus(_account, amount_fetched_change: _fetched.length);

    // notify of progress update
    notify(CmdMgrCmdNotifProgressUpdate(getProgressDescription()));

    try {
      _amplitude?.logEvent("EMAILS_FETCHED", eventProperties: {
        "count" : _fetched.length,
        "saved" : _save.length
      });
    } catch (e) {
      _log.severe(e);
    }

    _decisionStrategySpam.addSpamCards(_account, _save);
    _graphStrategyEmail.write(_save);
    if(status == CmdMgrCmdStatus.running) _getPartsAndFetchMsg();
  }

  Future<void> _saveMessages(List<EmailMsgModel> save) async {
    _log.fine('Saving ${save.length} messages');
    await _emailService.upsertMessages(save);
  }

  Future<void> _saveSenders(Map<String, EmailSenderModel> senders) async {
    senders.forEach((email, sender) {
      List<DateTime?> dates = _save.map((msg) {
        if (msg.sender?.email == email) return msg.receivedDate;
      }).toList();
      DateTime? since = dates.reduce((min, date) =>
      min != null && date != null && date.isBefore(min)
          ? date
          : min);
      sender.emailSince = since;
      senders[sender.email!] = sender;
    });
    _log.fine('Saving ${senders.length} senders');
    await _emailService.upsertSenders(List.of(senders.values));
  }

  Future<void> _saveCompanies(Map<String, EmailSenderModel> senders) async {
    Set<String> domains = {};
    for (var sender in senders.values) {
      if (sender.company?.domain != null) {
        domains.add(sender.company!.domain!);
      }
    }
    _log.fine('Saving ${domains.length} companies');
    for (String domain in domains) {
      _companyService.upsert(domain);
    }
  }

  @override
  num getProgress() {
    return _amountFetched / _totalToFetch;
  }

  @override
  String getProgressDescription() {
    return "${_amountFetched}/${_totalToFetch} emails fetched";
  }

}
