/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_localgraph/tiki_localgraph_edge.dart';
import 'package:tiki_localgraph/tiki_localgraph_vertex.dart';

import '../email/msg/email_msg_model.dart';
import 'graph_strategy.dart';

class GraphStrategyEmail extends GraphStrategy {
  Amplitude? amplitude;

  GraphStrategyEmail(TikiLocalGraph localGraph, {this.amplitude}) : super(localGraph);

  Future<List<String>> write(List<EmailMsgModel> emails) {
    if (emails.length > 0)
      return localGraph.add(_edges(emails));
    else
      return Future.value(List.empty());
  }

  List<TikiLocalGraphEdge> _edges(List<EmailMsgModel> emails) {
    List<TikiLocalGraphEdge> edges = [];
    emails.forEach((email) {
      String occ = _occurrence(email);
      edges.add(TikiLocalGraphEdge(
          TikiLocalGraphVertex(GraphStrategy.edgeTypeOccurrence, occ),
          TikiLocalGraphVertex(
              GraphStrategy.edgeTypeAction, 'email_received')));
      if (email.receivedDate != null) {
        edges.add(TikiLocalGraphEdge(
            TikiLocalGraphVertex(GraphStrategy.edgeTypeOccurrence, occ),
            TikiLocalGraphVertex(
                GraphStrategy.edgeTypeDate, _date(email.receivedDate!))));
      }
      if (email.subject != null) {
        edges.add(TikiLocalGraphEdge(
            TikiLocalGraphVertex(GraphStrategy.edgeTypeOccurrence, occ),
            TikiLocalGraphVertex(
                GraphStrategy.edgeTypeSubject, email.subject!)));
      }
      if (email.sender?.company?.domain != null) {
        edges.add(TikiLocalGraphEdge(
            TikiLocalGraphVertex(GraphStrategy.edgeTypeOccurrence, occ),
            TikiLocalGraphVertex(GraphStrategy.edgeTypeCompany,
                email.sender!.company!.domain!)));
      }
    });
    if(amplitude != null){
      amplitude!.logEvent(" CREATED_SIGNALS", eventProperties: {
        "count" : edges.length
      });
    }
    return edges;
  }

  String _date(DateTime timestamp) =>
      '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

  String _occurrence(EmailMsgModel email) {
    BytesBuilder builder = BytesBuilder();
    builder.add(utf8.encode(email.sender!.email!));
    builder.add(utf8.encode(email.subject!));
    builder.add(utf8.encode(_timeBlock(email.receivedDate!).toString()));
    return base64.encode(sha256(builder.toBytes(), sha3: true));
  }

  int _timeBlock(DateTime timestamp) {
    int truncated = (timestamp.millisecondsSinceEpoch / (100000000)).round();
    return (truncated / 5).round() * 5;
  }
}
