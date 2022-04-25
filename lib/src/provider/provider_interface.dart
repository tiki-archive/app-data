/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/cupertino.dart';

import '../account/account_interface.dart';
import '../email/email_interface.dart';

abstract class ProviderInterface<T> with AccountInterface<T>, EmailInterface {
  Widget get widget;
}
