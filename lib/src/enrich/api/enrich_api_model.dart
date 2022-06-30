/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'enrich_api_data.dart';
import 'enrich_api_model_msg.dart';
import 'enrich_api_model_page.dart';

class EnrichApiModel<T extends EnrichApiData> {
  String? status;
  int? code;
  T? data;
  EnrichApiModelPage? page;
  List<EnrichApiModelMsg>? messages;

  EnrichApiModel({this.status, this.code, this.data, this.page, this.messages});

  EnrichApiModel.fromJson(Map<String, dynamic>? json,
      {T Function(Map<String, dynamic>? json)? fromJson}) {
    if (json != null) {
      status = json['status'];
      code = json['code'];
      if (json['data'] != null && fromJson != null) {
        data = json['data'] is List
            ? json['data'].map((e) => fromJson(e)).toList()
            : fromJson(json['data']);
      }
      if (json['page'] != null) {
        page = EnrichApiModelPage().fromJson(json['page']);
      }
      if (json['messages'] != null) {
        messages = (json['messages'] as List)
            .map((e) => EnrichApiModelMsg.fromJson(e))
            .toList();
      }
    }
  }

  Map<String, dynamic> toJson() =>
      {
        'status': status,
        'code': code,
        'data': data?.toJson(),
        'page': page?.toJson(),
        'messages': messages?.map((e) => e.toJson()).toList()
      };

  @override
  String toString() =>
      '''EnrichApiModel
status: $status,
code: $code,
data: ${data?.toJson()},
page: ${page?.toJson()},
messages: ${messages?.map((e) => e.toJson())}
''';

}