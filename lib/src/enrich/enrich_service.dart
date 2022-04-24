/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import 'api/enrich_api_model.dart';
import 'company/enrich_company_model.dart';
import 'company/enrich_company_repository.dart';

class EnrichService {
  final _log = Logger('EnrichService');
  final HttppClient _client;
  final EnrichCompanyRepository _companyRepository;
  final Future<void> Function(void Function(String?)? onSuccess)? refresh;

  EnrichService({Httpp? httpp, this.refresh})
      : _client = httpp == null ? Httpp().client() : httpp.client(),
        _companyRepository = EnrichCompanyRepository();

  Future<void> getCompany(
          {required String domain,
          String? accessToken,
          Function(Object)? onError,
          Function(EnrichCompanyModel?)? onSuccess}) =>
      _refresh(accessToken, (err) {
        _log.severe(err);
        if (onError != null) onError(err);
      },
          (token, onError) => _companyRepository.get(
              client: _client,
              accessToken: token,
              domain: domain,
              onSuccess: onSuccess,
              onError: onError));

  Future<T> _refresh<T>(
      String? accessToken,
      Function(Object)? onError,
      Future<T> Function(String?, Future<void> Function(Object))
          request) async {
    return request(accessToken, (error) async {
      if (error is EnrichApiModel && error.code == 401 && refresh != null) {
        await refresh!((token) async {
          if (token != null)
            await request(
                token,
                (error) async =>
                    onError != null ? onError(error) : throw error);
        });
      } else
        onError != null ? onError(error) : throw error;
    });
  }
}
