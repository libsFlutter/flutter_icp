import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/icp_exceptions.dart';
import '../models/icp_account.dart';
import 'icp_socket_manager.dart';

/// Расширенный сервис ICP с поддержкой Socket.IO
class EnhancedICPService {
  final String _networkUrl;
  final ICPSocketManager? _socketManager;

  EnhancedICPService({
    required String networkUrl,
    ICPSocketManager? socketManager,
  })  : _networkUrl = networkUrl,
        _socketManager = socketManager;

  /// Получение информации об аккаунте
  Future<ICPAccount> getAccount(String principal) async {
    try {
      final response = await http.get(
        Uri.parse('$_networkUrl/api/account/$principal'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ICPAccount.fromJson(data);
      } else {
        throw ICPNetworkException(
            'Failed to fetch account: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPNetworkException('Error fetching account: $e');
    }
  }

  /// Получение истории транзакций
  Future<List<ICPTransaction>> getTransactions(String principal,
      {int? limit}) async {
    try {
      final url = Uri.parse('$_networkUrl/api/transactions/$principal').replace(
        queryParameters: limit != null ? {'limit': limit.toString()} : {},
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ICPTransaction.fromJson(json)).toList();
      } else {
        throw ICPNetworkException(
            'Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPNetworkException('Error fetching transactions: $e');
    }
  }

  /// Отправка ICP
  Future<String> sendICP(String from, String to, BigInt amount,
      {String? memo}) async {
    try {
      final response = await http.post(
        Uri.parse('$_networkUrl/api/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'from': from,
          'to': to,
          'amount': amount.toString(),
          'memo': memo,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['transaction_id'] as String;
      } else {
        throw ICPTransactionException(
            'Failed to send ICP: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPTransactionException('Error sending ICP: $e');
    }
  }

  /// Получение списка канистеров
  Future<List<ICPCanisterInfo>> getCanisters(String principal) async {
    try {
      final response = await http.get(
        Uri.parse('$_networkUrl/api/canisters/$principal'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ICPCanisterInfo.fromJson(json)).toList();
      } else {
        throw ICPNetworkException(
            'Failed to fetch canisters: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPNetworkException('Error fetching canisters: $e');
    }
  }

  /// Вызов метода канистера
  Future<String> callCanister(
      String canisterId, String method, Map<String, dynamic> args) async {
    try {
      final response = await http.post(
        Uri.parse('$_networkUrl/api/canister/$canisterId/call'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'method': method,
          'args': args,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['request_id'] as String;
      } else {
        throw ICPCanisterException(
            'Failed to call canister: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPCanisterException('Error calling canister: $e');
    }
  }

  /// Запрос к канистеру
  Future<Map<String, dynamic>> queryCanister(
      String canisterId, String method, Map<String, dynamic> args) async {
    try {
      final response = await http.post(
        Uri.parse('$_networkUrl/api/canister/$canisterId/query'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'method': method,
          'args': args,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ICPCanisterException(
            'Failed to query canister: ${response.statusCode}');
      }
    } catch (e) {
      throw ICPCanisterException('Error querying canister: $e');
    }
  }

  /// Подключение к аккаунту через Socket.IO
  void connectToAccount(String principal) {
    _socketManager?.connectToAccount(principal);
  }

  /// Отключение от аккаунта
  void disconnectFromAccount(String principal) {
    _socketManager?.disconnectFromAccount(principal);
  }

  /// Поток новых транзакций
  Stream<ICPTransaction>? get transactionStream =>
      _socketManager?.transactionStream;

  /// Поток обновлений баланса
  Stream<Map<String, dynamic>>? get balanceStream =>
      _socketManager?.balanceStream;

  /// Поток статуса канистеров
  Stream<Map<String, dynamic>>? get canisterStatusStream =>
      _socketManager?.canisterStatusStream;
}
