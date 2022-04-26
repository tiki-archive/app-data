/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class AccountModelProvider {
  final String _value;

  const AccountModelProvider(this._value);

  static const google = AccountModelProvider('google');
  static const microsoft = AccountModelProvider('microsoft');
  static const values = [google, microsoft];

  String get value => _value;

  static AccountModelProvider? fromValue(String? s) {
    if (s != null) {
      for (AccountModelProvider provider in values) {
        if (provider.value == s) return provider;
      }
    }
    return null;
  }
}
