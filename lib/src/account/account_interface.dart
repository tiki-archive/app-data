/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'account_model.dart';

abstract class AccountInterface<T> {
  Future<bool> isConnected(AccountModel account);
}
