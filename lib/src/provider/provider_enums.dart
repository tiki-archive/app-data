/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

enum ProviderEnum { google, microsoft }

extension ProviderExtension on ProviderEnum {
  String get value {
    switch (this) {
      case ProviderEnum.google:
        return 'google';
      case ProviderEnum.microsoft:
        return 'microsoft';
    }
  }
}
