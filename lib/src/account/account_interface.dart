/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:httpp/httpp.dart';

import 'account_model.dart';

abstract class AccountInterface {
  Future<bool> isConnected(AccountModel account);
}
