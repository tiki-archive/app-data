/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class FetchApiEnum {
  final String _value;

  const FetchApiEnum._(this._value);

  static const gmail = FetchApiEnum._('gmail');
  static const outlook = FetchApiEnum._('outlook');

  static const values = [gmail, outlook];

  String get value => _value;

  static FetchApiEnum? fromValue(String? s) {
    if (s != null) {
      for (FetchApiEnum api in values) {
        if (api.value == s) return api;
      }
    }
    return null;
  }
}
