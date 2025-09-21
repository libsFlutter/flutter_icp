import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'icp_config.dart';
import 'icp_types.dart';
import 'icp_exceptions.dart';

/// Main client for Internet Computer Protocol operations
class ICPClient {
  static ICPClient? _instance;
  static ICPClient get instance => _instance ??= ICPClient._internal();
  
  ICPClient._internal();

  final ICPConfig _config = ICPConfig.instance;
  final http.Client _httpClient = http.Client();
  bool _isInitialized = false;
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Whether the client is initialized
  bool get isInitialized => _isInitialized;

  /// Current network configuration
  ICPNetworkConfig get networkConfig => _config.networkConfig;

  /// Initialize the ICP client
  Future<void> initialize() async {
    if (_isInitialized) {
      throw ICPServiceAlreadyInitializedException('ICP client is already initialized');
    }

    if (!_config.validate()) {
      throw ICPConfigurationException('Invalid ICP configuration');
    }

    try {
      // Test network connectivity
      await _testNetworkConnectivity();
      
      _isInitialized = true;
      
      if (_config.debugLogging) {
        developer.log('ICP Client initialized successfully');
        developer.log('Network: ${_config.networkConfig.name}');
        developer.log('URL: ${_config.networkConfig.url}');
      }
    } catch (e) {
      throw ICPServiceNotInitializedException('Failed to initialize ICP client: $e');
    }
  }

  /// Dispose the ICP client
  Future<void> dispose() async {
    _httpClient.close();
    _cache.clear();
    _cacheTimestamps.clear();
    _isInitialized = false;
  }

  /// Test network connectivity
  Future<void> _testNetworkConnectivity() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('${_config.networkUrl}/api/v2/status'),
            headers: _getHeaders(),
          )
          .timeout(Duration(milliseconds: _config.requestTimeout));

      if (response.statusCode != 200) {
        throw ICPNetworkException('Network connectivity test failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw ICPTimeoutException('Network connectivity test timed out');
      }
      throw ICPNetworkException('Network connectivity test failed: $e');
    }
  }

  /// Make a query call to an ICP canister
  Future<Map<String, dynamic>> query({
    required String canisterId,
    required String method,
    Map<String, dynamic>? args,
  }) async {
    _ensureInitialized();

    final cacheKey = 'query_${canisterId}_$method';
    if (_config.enableCaching && _isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      final requestBody = {
        'request_type': 'call',
        'canister_id': canisterId,
        'method_name': method,
        'arg': args != null ? base64Encode(utf8.encode(jsonEncode(args))) : '',
      };

      final response = await _httpClient
          .post(
            Uri.parse('${_config.networkUrl}/api/v2/canister/$canisterId/query'),
            headers: _getHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: ICPConfig.defaultQueryTimeout));

      if (response.statusCode != 200) {
        throw ICPQueryException('Query call failed: ${response.statusCode}');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (result.containsKey('error')) {
        throw ICPQueryException('Query call error: ${result['error']}');
      }

      // Cache the result
      if (_config.enableCaching) {
        _cache[cacheKey] = result;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return result;
    } catch (e) {
      if (e is TimeoutException) {
        throw ICPTimeoutException('Query call timed out');
      }
      if (e is ICPException) {
        rethrow;
      }
      throw ICPQueryException('Query call failed: $e');
    }
  }

  /// Make an update call to an ICP canister
  Future<Map<String, dynamic>> update({
    required String canisterId,
    required String method,
    Map<String, dynamic>? args,
    Map<String, dynamic>? options,
  }) async {
    _ensureInitialized();

    try {
      final requestBody = {
        'request_type': 'call',
        'canister_id': canisterId,
        'method_name': method,
        'arg': args != null ? base64Encode(utf8.encode(jsonEncode(args))) : '',
        'sender': options?['sender'],
        'ingress_expiry': options?['ingress_expiry'] ?? _getIngressExpiry(),
      };

      final response = await _httpClient
          .post(
            Uri.parse('${_config.networkUrl}/api/v2/canister/$canisterId/call'),
            headers: _getHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(seconds: ICPConfig.defaultTransactionTimeout));

      if (response.statusCode != 200) {
        throw ICPUpdateException('Update call failed: ${response.statusCode}');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (result.containsKey('error')) {
        throw ICPUpdateException('Update call error: ${result['error']}');
      }

      return result;
    } catch (e) {
      if (e is TimeoutException) {
        throw ICPTimeoutException('Update call timed out');
      }
      if (e is ICPException) {
        rethrow;
      }
      throw ICPUpdateException('Update call failed: $e');
    }
  }

  /// Get canister information
  Future<Map<String, dynamic>> getCanisterInfo(String canisterId) async {
    _ensureInitialized();

    final cacheKey = 'canister_info_$canisterId';
    if (_config.enableCaching && _isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      final response = await _httpClient
          .get(
            Uri.parse('${_config.networkUrl}/api/v2/canister/$canisterId/status'),
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: ICPConfig.defaultQueryTimeout));

      if (response.statusCode != 200) {
        throw ICPQueryException('Failed to get canister info: ${response.statusCode}');
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Cache the result
      if (_config.enableCaching) {
        _cache[cacheKey] = result;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return result;
    } catch (e) {
      if (e is TimeoutException) {
        throw ICPTimeoutException('Get canister info timed out');
      }
      if (e is ICPException) {
        rethrow;
      }
      throw ICPQueryException('Failed to get canister info: $e');
    }
  }

  /// Get ICP balance for an account
  Future<double> getBalance(String accountId) async {
    _ensureInitialized();

    try {
      final ledgerCanisterId = _config.getCanisterId('ledger');
      if (ledgerCanisterId == null) {
        throw ICPConfigurationException('Ledger canister ID not configured');
      }

      final result = await query(
        canisterId: ledgerCanisterId,
        method: 'account_balance',
        args: {'account': accountId},
      );

      return (result['balance'] as num).toDouble();
    } catch (e) {
      if (e is ICPException) {
        rethrow;
      }
      throw ICPQueryException('Failed to get balance: $e');
    }
  }

  /// Get transaction history for an account
  Future<List<Map<String, dynamic>>> getTransactionHistory(String accountId, {int? limit}) async {
    _ensureInitialized();

    try {
      final ledgerCanisterId = _config.getCanisterId('ledger');
      if (ledgerCanisterId == null) {
        throw ICPConfigurationException('Ledger canister ID not configured');
      }

      final result = await query(
        canisterId: ledgerCanisterId,
        method: 'query_transactions',
        args: {
          'account': accountId,
          'limit': limit ?? 100,
        },
      );

      return List<Map<String, dynamic>>.from(result['transactions'] ?? []);
    } catch (e) {
      if (e is ICPException) {
        rethrow;
      }
      throw ICPQueryException('Failed to get transaction history: $e');
    }
  }

  /// Get headers for HTTP requests
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add custom headers
    headers.addAll(_config.customHeaders);

    return headers;
  }

  /// Get ingress expiry timestamp
  int _getIngressExpiry() {
    final now = DateTime.now();
    final expiry = now.add(Duration(minutes: 5));
    return expiry.millisecondsSinceEpoch * 1000000; // Convert to nanoseconds
  }

  /// Check if cache entry is valid
  bool _isCacheValid(String key) {
    if (!_config.enableCaching) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    final diff = now.difference(timestamp).inSeconds;
    return diff < _config.cacheTtl;
  }

  /// Ensure client is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw ICPServiceNotInitializedException('ICP client is not initialized');
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'entries': _cache.length,
      'enabled': _config.enableCaching,
      'ttl': _config.cacheTtl,
    };
  }

  /// Get client statistics
  Map<String, dynamic> getStats() {
    return {
      'initialized': _isInitialized,
      'network': _config.networkConfig.name,
      'url': _config.networkConfig.url,
      'isTestnet': _config.networkConfig.isTestnet,
      'cache': getCacheStats(),
    };
  }
}
