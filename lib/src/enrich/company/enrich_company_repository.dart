/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../api/enrich_api_model.dart';
import 'enrich_company_model.dart';

class EnrichCompanyRepository {
  final Logger _log = Logger('EnrichCompanyRepository');
  static const String _path = '/api/latest/vertex/company';

  Future<void> get(
      {required HttppClient client,
      String? accessToken,
      required String domain,
      void Function(EnrichCompanyModel?)? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.https('knowledge.mytiki.com', _path, {'domain': domain}),
        verb: HttppVerb.GET,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        timeout: const Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) {
            EnrichApiModel<EnrichCompanyModel> body = EnrichApiModel.fromJson(
                rsp.body?.jsonBody,
                fromJson: (json) => EnrichCompanyModel.fromJson(json));
            onSuccess(body.data);
          }
        },
        onResult: (rsp) {
          EnrichApiModel body = EnrichApiModel.fromJson(rsp.body?.jsonBody);
          if (onError != null) onError(body);
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }
}
