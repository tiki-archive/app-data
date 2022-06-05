/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class FetchEmailApiEnum {
  final String _value;

  const FetchEmailApiEnum._(this._value);

  static const gmail = FetchEmailApiEnum._('gmail');
  static const outlook = FetchEmailApiEnum._('outlook');

  static const values = [gmail, outlook];

  String get value => _value;

  static FetchEmailApiEnum? fromValue(String? s) {
    if (s != null) {
      for (FetchEmailApiEnum api in values) {
        if (api.value == s) return api;
      }
    }
    return null;
  }
}
