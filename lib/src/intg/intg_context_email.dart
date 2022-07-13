/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../account/account_service.dart';
import '../email/msg/email_msg_model.dart';
import 'intg_context.dart';
import 'intg_strategy_google_email.dart';
import 'intg_strategy_interface_email.dart';
import 'intg_strategy_microsoft_email.dart';

class IntgContextEmail extends IntgContext {
  IntgContextEmail(AccountService accountService, {Httpp? httpp})
      : super(accountService, httpp: httpp);

  Future<void> getInbox(
          {required AccountModel account,
          DateTime? since,
          String? page,
          required Function(List<EmailMsgModel> messages, {String? page}) onResult,
          required Function() onFinish}) =>
      _strategy(account.provider)!.getInbox(
          account: account,
          page: page,
          since: since,
          onResult: onResult,
          onFinish: onFinish);

  Future<void> getMessages(
          {required AccountModel account,
          required List<String> messageIds,
          required Function(EmailMsgModel message) onResult,
          required Function() onFinish}) =>
      _strategy(account.provider)!.getMessages(
          account: account,
          messageIds: messageIds,
          onResult: onResult,
          onFinish: onFinish);

  Future<void> send(
          {required AccountModel account,
          String? body,
          required String to,
          String? subject,
          Function(bool success)? onResult}) =>
      _strategy(account.provider)!.send(
          account: account,
          body: body,
          to: to,
          subject: subject,
          onResult: onResult);

  IntgStrategyInterfaceEmail? _strategy(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return IntgStrategyGoogleEmail(accountService, httpp: httpp);
      case AccountModelProvider.microsoft:
        return IntgStrategyMicrosoftEmail(accountService, httpp: httpp);
      default:
        return null;
    }
  }
}
