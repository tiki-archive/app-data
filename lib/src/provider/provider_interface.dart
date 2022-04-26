/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/cupertino.dart';

import '../account/account_interface.dart';
import '../email/email_interface.dart';

abstract class ProviderInterface with AccountInterface, EmailInterface {
  Widget get widget;
}
