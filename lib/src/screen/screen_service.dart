/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:decision/decision.dart';
import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';
import 'package:spam_cards/spam_cards.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../email/email_interface.dart';
import '../email/email_service.dart';
import '../email/sender/email_sender_model.dart';
import '../fetch/fetch_service.dart';
import '../provider/provider_google.dart';
import '../provider/provider_interface.dart';
import '../provider/provider_microsoft.dart';
import 'screen_controller.dart';
import 'screen_model.dart';
import 'screen_presenter.dart';

class ScreenService extends ChangeNotifier {
  final ScreenModel model = ScreenModel();
  late final ScreenController controller;
  late final ScreenPresenter presenter;
  final Httpp? httpp;

  final AccountService _accountService;
  final FetchService _fetchService;
  final SpamCards _spamCards;
  final Decision _decision;
  final EmailService _emailService;

  ScreenService(this._accountService, this._fetchService, this._spamCards,
      this._decision, this._emailService,
      {this.httpp}) {
    controller = ScreenController(this);
    presenter = ScreenPresenter(this);
    _accountService.getAll().then((accounts) {
      model.addAll(accounts);
      if (model.first() != null) fetchInbox(model.first()!);
      notifyListeners();
    });
  }

  Future<void> saveAccount(AccountModel account) async {
    model.add(account);
    await _accountService.save(account);
    _decision.setLinked(true);
    fetchInbox(account);
  }

  Future<void> removeAccount(AccountModelProvider type, String username) async {
    model.remove(type, username);
    await _accountService.remove(username, type.value);
    _decision.setLinked(false);
    notifyListeners();
  }

  fetchInbox(AccountModel account) {
    _fetchService.asyncIndex(account, onFinishProccess: _addSpamCards);
    notifyListeners();
  }

  _addSpamCards(List messages) {
    _spamCards.addCards(
        provider: model.first()!.provider!.value,
        messages: messages,
        onUnsubscribe: _unsubscribeFromSpam,
        onKeep: _keepReceiving);
  }

  Future<bool> _unsubscribeFromSpam(String senderEmail) async {
    AccountModel account = model.first()!;
    EmailInterface? emailInterface = await _getEmailInterface(account);
    if (emailInterface == null) throw 'Invalid email interface';
    EmailSenderModel? sender =
        await _emailService.getSenderByEmail(senderEmail);
    if (sender == null) throw 'Invalid sender';
    String unsubscribeMailTo = sender.unsubscribeMailTo!;
    Uri uri = Uri.parse(unsubscribeMailTo);
    String to = uri.path;
    String list = sender.name ?? sender.email!;
    String subject = uri.queryParameters['subject'] ?? "Unsubscribe from $list";
    String body = '''
Hello,<br /><br />
I'd like to stop receiving emails from this email list.<br /><br />
Thanks,<br /><br />
${account.displayName ?? ''}<br />
<br />
''';
    bool success = false;
    await emailInterface.send(
        account: account,
        to: to,
        body: body,
        subject: subject,
        onResult: (res) => success = res);
    return success;
  }

  Future<void> _keepReceiving(String senderEmail) async {
    EmailSenderModel? sender =
        await _emailService.getSenderByEmail(senderEmail);
    if (sender != null) {
      await _emailService.markAsKept(sender);
    }
  }

  ProviderInterface? _getEmailInterface(AccountModel account) {
    switch (account.provider) {
      case AccountModelProvider.google:
        return ProviderGoogle(account: account, httpp: httpp);
      case AccountModelProvider.microsoft:
        return ProviderMicrosoft(account: account, httpp: httpp);
      default:
        return null;
    }
  }
}
