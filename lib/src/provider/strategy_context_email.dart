/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../email/msg/email_msg_model.dart';
import 'strategy_context.dart';
import 'strategy_google_email.dart';
import 'strategy_interface_email.dart';

class StrategyContextEmail extends StrategyContext {
  StrategyContextEmail({Httpp? httpp}) : super(httpp: httpp);

  Future<void> getInbox(
          {required AccountModel account,
          DateTime? since,
          required Function(List<EmailMsgModel> messages) onResult,
          required Function() onFinish}) =>
      _strategy(account.provider)!.getInbox(
          account: account,
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

  StrategyInterfaceEmail? _strategy(AccountModelProvider? provider) {
    switch (provider) {
      case AccountModelProvider.google:
        return StrategyGoogleEmail(httpp);
      default:
        return null;
    }
  }
}
