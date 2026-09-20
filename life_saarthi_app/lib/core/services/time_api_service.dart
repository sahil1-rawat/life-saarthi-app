import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:life_saarthi_app/core/utils/app_logger_utils.dart';

import '../constants/api_constants.dart';

class TimeApiService {
  TimeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DateTime> getServerTime() async {
    final response = await _client.get(Uri.parse(ApiConstants.serverTime));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch server time. '
        'Status code: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final serverTime = data['server_time'];
    AppLogger.log("server time:$serverTime");
    if (serverTime is! String) {
      throw const FormatException('Invalid server time response.');
    }

    return DateTime.parse(serverTime).toUtc();
  }
}
