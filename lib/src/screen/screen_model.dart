/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import '../provider/provider_enum.dart';

class ScreenModel {
  Set<AccountModel> _accounts;

  ScreenModel({Set<AccountModel>? accounts}) : _accounts = accounts ?? Set();

  Set<AccountModel> get accounts => _accounts;

  AccountModel? first() => _accounts.length > 0 ? _accounts.first : null;

  void add(AccountModel account) => _accounts.add(account);

  void addAll(List<AccountModel> accounts) => _accounts.addAll(accounts);

  void remove(ProviderEnum type, String username) =>
      _accounts.removeWhere((account) =>
          account.provider == type.value && account.username == username);
}
