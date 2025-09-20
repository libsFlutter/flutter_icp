import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/icp_client.dart';
import '../core/icp_config.dart';
import '../core/icp_exceptions.dart';

/// Service for general ICP blockchain operations
class IcpService {
  final IcpClient _client;
  final IcpConfig _config;

  const IcpService({
    required IcpClient client,
    required IcpConfig config,
  })  : _client = client,
        _config = config;

  /// Get account balance
  Future<double> getBalance(String address) async {
    try {
      final response = await _client.get('/balance/$address');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['balance'] as num).toDouble();
      } else {
        throw IcpException('Failed to get balance: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error getting balance: $e');
    }
  }

  /// Transfer ICP tokens
  Future<String> transfer({
    required String to,
    required double amount,
    String? memo,
  }) async {
    try {
      final body = {
        'to': to,
        'amount': amount,
        if (memo != null) 'memo': memo,
      };

      final response = await _client.post('/transfer', body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactionId'] as String;
      } else {
        throw IcpException('Failed to transfer: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error transferring: $e');
    }
  }

  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory(
      String address) async {
    try {
      final response = await _client.get('/transactions/$address');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      } else {
        throw IcpException(
            'Failed to get transaction history: ${response.statusCode}');
      }
    } catch (e) {
      throw IcpException('Error getting transaction history: $e');
    }
  }
}
