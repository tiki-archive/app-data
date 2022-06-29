import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiki_data/src/enrich/api/enrich_api_model.dart';
import 'package:tiki_data/src/enrich/api/enrich_api_model_page.dart';
import 'package:tiki_data/src/enrich/api/enrich_api_model_msg.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Enrich API Tests', () {
    test("EnrichApiModel to String test", () async {
      String log = EnrichApiModel(
          status: 'ok',
          code: 200,
          page: EnrichApiModelPage(
              size: 10,
              totalElements: 100,
              totalPages: 1000,
              page: 2
          ),
          messages: [
            EnrichApiModelMsg.fromJson({
              'size': 100,
              'status': "OK",
              'message': "MESSAGE",
            })
          ]
      ).toString();
        expect(log, 'EnrichApiModel\n'
      'status: ok,\n'
      'code: 200,\n'
      'data: null,\n'
      'page: {size: 10, totalElements: 100, totalPages: 1000, page: 2},\n'
      'messages: ({size: null, status: OK, message: MESSAGE, properties: null})\n');
    });
  });
}