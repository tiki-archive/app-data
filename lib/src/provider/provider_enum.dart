/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class ProviderEnum {
  final String _value;

  const ProviderEnum(this._value);

  static const google = ProviderEnum('google');
  static const microsoft = ProviderEnum('microsoft');
  static const values = [google, microsoft];

  String get value => _value;

  static ProviderEnum? fromValue(String? s) {
    if (s != null) {
      for (ProviderEnum provider in values) {
        if (provider.value == s) return provider;
      }
    }
    return null;
  }
}
