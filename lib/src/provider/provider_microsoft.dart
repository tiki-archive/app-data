/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:httpp/httpp.dart';
import 'package:microsoft_provider/microsoft_provider.dart';

import '../account/account_model.dart';
import '../account/account_model_provider.dart';
import '../email/msg/email_msg_model.dart';
import 'provider_interface.dart';

class ProviderMicrosoft extends ProviderInterface {
  final MicrosoftProvider _microsoft;
  final Httpp _httpp;

  ProviderMicrosoft(
      {AccountModel? account,
      Function(MicrosoftProviderModel)? onLink,
      Function(String?)? onUnlink,
      Httpp? httpp})
      : _httpp = httpp ?? Httpp(),
        _microsoft = account != null
            ? MicrosoftProvider.loggedIn(
                token: account.accessToken,
                refreshToken: account.refreshToken,
                email: account.email,
                displayName: account.displayName,
                onLink: onLink,
                onUnlink: onUnlink,
                httpp: httpp)
            : MicrosoftProvider(
                onLink: onLink, onUnlink: onUnlink, httpp: httpp);

  @override
  Future<bool> isConnected(AccountModel account) {
    Completer<bool> completer = Completer();
    _microsoft.update(onUpdate: (account) => completer.complete(true)).timeout(
        Duration(seconds: 30),
        onTimeout: () => completer.complete(false));
    return completer.future;
  }

  @override
  Widget get widget => _microsoft.accountWidget();

  static AccountModel to(MicrosoftProviderModel raw) => AccountModel(
        username: raw.email,
        email: raw.email,
        displayName: raw.displayName,
        provider: AccountModelProvider.microsoft,
        accessToken: raw.token,
        accessTokenExpiration: raw.accessTokenExp,
        refreshToken: raw.refreshToken,
      );

  @override
  Future<void> getInbox(
      {required AccountModel account,
      DateTime? since,
      required Function(List<EmailMsgModel> messages) onResult,
      required Function() onFinish}) {
    return MicrosoftProvider.loggedIn(
            email: account.email,
            token: account.accessToken!,
            refreshToken: account.refreshToken,
            displayName: account.displayName,
            httpp: _httpp)
        .fetchInbox(
            onResult: (msgIdList) => onResult(msgIdList
                .map((msgId) => EmailMsgModel(extMessageId: msgId))
                .toList()),
            onFinish: onFinish);
  }

  @override
  Future<void> getMessages(
      {required AccountModel account,
      required List<String> messageIds,
      required Function(EmailMsgModel message) onResult,
      required Function() onFinish}) {
    return MicrosoftProvider.loggedIn(
            email: account.email,
            token: account.accessToken!,
            refreshToken: account.refreshToken,
            displayName: account.displayName,
            httpp: _httpp)
        .fetchMessages(
            messageIds: messageIds,
            onResult: (msg) => onResult(EmailMsgModel.fromMap(msg.toJson())),
            onFinish: onFinish);
  }

  @override
  Future<void> send(
      {required AccountModel account,
      String? body,
      required String to,
      String? subject,
      Function(bool success)? onResult}) {
    return MicrosoftProvider.loggedIn(
            email: account.email,
            token: account.accessToken!,
            refreshToken: account.refreshToken,
            displayName: account.displayName,
            httpp: _httpp)
        .sendEmail(body: body, to: to, subject: subject, onResult: onResult);
  }
}
