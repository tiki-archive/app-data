/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class ProviderEnum {
  final String _value;

  const ProviderEnum(this._value);

  static const String _googleValue = 'google';
  static const String _microsoftValue = 'microsoft';

  static const google = ProviderEnum(_googleValue);
  static const microsoft = ProviderEnum(_microsoftValue);

  String get value => _value;

  static ProviderEnum? fromValue(String value) {
    switch (value) {
      case _googleValue:
        return google;
      case _microsoftValue:
        return microsoft;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderEnum &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
