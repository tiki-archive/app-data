/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_localgraph/tiki_localgraph_edge.dart';
import 'package:tiki_localgraph/tiki_localgraph_vertex.dart';

import '../email/msg/email_msg_model.dart';
import 'graph_strategy.dart';

class GraphStrategyEmail extends GraphStrategy {
  final String? Function() accessToken;

  GraphStrategyEmail(TikiLocalGraph localGraph,
      {String? Function()? accessToken})
      : accessToken = accessToken ?? (() => null),
        super(localGraph);

  write(List<EmailMsgModel> emails) =>
      localGraph.add(_edges(emails), accessToken: accessToken());

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
