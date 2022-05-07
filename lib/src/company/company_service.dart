/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../enrich/enrich_service.dart';
import 'company_model.dart';
import 'company_repository.dart';

class CompanyService {
  final _log = Logger('CompanyService');
  final EnrichService _enrichService;
  late final CompanyRepository _repository;

  CompanyService(this._enrichService);

  Future<CompanyService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repository = CompanyRepository(database);
    await _repository.createTable();
    return this;
  }

  Future<void> upsert(String domain,
      {Function(CompanyModel?)? onComplete}) async {
    if (domain.isNotEmpty) {
      CompanyModel? local = await _repository.getByDomain(domain);
      if (local == null) {
        await _enrichService.getCompany(
            domain: domain,
            onSuccess: (company) async {
              CompanyModel saved = await _repository.insert(CompanyModel(
                domain: domain,
                logo: company?.about?.logo,
                securityScore: company?.score?.securityScore,
                breachScore: company?.score?.breachScore,
                sensitivityScore: company?.score?.sensitivityScore,
              ));
              if (onComplete != null) onComplete(saved);
            },
            onError: (error) => _log.warning(error));
      } else if (local.modified == null ||
          local.securityScore == null ||
          local.modified!
              .isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
        await _enrichService.getCompany(
            domain: domain,
            onSuccess: (company) async {
              CompanyModel saved = await _repository.update(CompanyModel(
                  companyId: local.companyId,
                  domain: domain,
                  logo: company?.about?.logo,
                  securityScore: company?.score?.securityScore,
                  breachScore: company?.score?.breachScore,
                  sensitivityScore: company?.score?.sensitivityScore,
                  created: local.created,
                  modified: local.modified));
              if (onComplete != null) onComplete(saved);
            },
            onError: (error) => _log.warning(error));
      } else if (onComplete != null) {
        onComplete(local);
      }
    }
  }
}
