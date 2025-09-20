import 'package:flutter_icp/src/core/icp_client.dart';
import 'package:mockito/mockito.dart';

/// Mock implementation of ICPClient for testing
class MockICPClient extends Mock implements ICPClient {
  bool _isInitialized = false;
  final Map<String, dynamic> _mockData = {};
  
  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _mockData.clear();
  }

  @override
  Future<Map<String, dynamic>> query({
    required String canisterId,
    required String method,
    Map<String, dynamic>? args,
  }) async {
    if (!_isInitialized) {
      throw Exception('Client not initialized');
    }
    
    final key = '${canisterId}_$method';
    return _mockData[key] ?? _getDefaultQueryResponse(method, args);
  }

  @override
  Future<Map<String, dynamic>> update({
    required String canisterId,
    required String method,
    Map<String, dynamic>? args,
    Map<String, dynamic>? options,
  }) async {
    if (!_isInitialized) {
      throw Exception('Client not initialized');
    }
    
    return _getDefaultUpdateResponse(method, args);
  }

  @override
  Future<Map<String, dynamic>> getCanisterInfo(String canisterId) async {
    if (!_isInitialized) {
      throw Exception('Client not initialized');
    }
    
    return {
      'canister_id': canisterId,
      'status': 'running',
      'memory_size': 1000000,
      'cycles': 5000000000000,
    };
  }

  @override
  Future<double> getBalance(String accountId) async {
    if (!_isInitialized) {
      throw Exception('Client not initialized');
    }
    
    return 10.5; // Mock balance
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionHistory(String accountId, {int? limit}) async {
    if (!_isInitialized) {
      throw Exception('Client not initialized');
    }
    
    return [
      {
        'id': 'tx_1',
        'from': 'account_1',
        'to': 'account_2',
        'amount': 1.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }
    ];
  }

  void setMockData(String canisterId, String method, Map<String, dynamic> data) {
    _mockData['${canisterId}_$method'] = data;
  }

  Map<String, dynamic> _getDefaultQueryResponse(String method, Map<String, dynamic>? args) {
    switch (method) {
      case 'get_tokens_by_owner':
        return {
          'tokens': [
            {
              'id': 'nft_1',
              'token_id': '1',
              'canister_id': 'test-canister',
              'owner': args?['owner'] ?? 'test-owner',
              'metadata': {
                'name': 'Test NFT',
                'description': 'Test NFT Description',
                'image': 'https://example.com/image.png',
                'attributes': {'color': 'blue'},
                'properties': {'type': 'test'},
              },
              'creator': 'test-creator',
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
              'status': 'active',
            }
          ]
        };
      case 'get_token':
        return {
          'token': {
            'id': 'nft_1',
            'token_id': args?['token_id'] ?? '1',
            'canister_id': 'test-canister',
            'owner': 'test-owner',
            'metadata': {
              'name': 'Test NFT',
              'description': 'Test NFT Description',
              'image': 'https://example.com/image.png',
              'attributes': {'color': 'blue'},
              'properties': {'type': 'test'},
            },
            'creator': 'test-creator',
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
            'status': 'active',
          }
        };
      case 'is_approved':
        return {'approved': true};
      case 'get_token_metadata':
        return {
          'metadata': {
            'name': 'Test NFT',
            'description': 'Test NFT Description',
            'image': 'https://example.com/image.png',
            'attributes': {'color': 'blue'},
            'properties': {'type': 'test'},
          }
        };
      case 'search_tokens':
        return {
          'tokens': [
            {
              'id': 'nft_1',
              'token_id': '1',
              'canister_id': 'test-canister',
              'owner': 'test-owner',
              'metadata': {
                'name': 'Test NFT',
                'description': 'Test NFT Description',
                'image': 'https://example.com/image.png',
                'attributes': {'color': 'blue'},
                'properties': {'type': 'test'},
              },
              'creator': 'test-creator',
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
              'status': 'active',
            }
          ]
        };
      case 'get_transaction_status':
        return {'status': 'confirmed'};
      case 'get_transaction':
        return {
          'id': args?['transaction_id'] ?? 'tx_1',
          'status': 'confirmed',
          'from': 'test-from',
          'to': 'test-to',
          'amount': 1.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      case 'account_balance':
        return {'balance': 10500000000}; // 10.5 ICP in e8s
      case 'query_transactions':
        return {
          'transactions': [
            {
              'id': 'tx_1',
              'from': 'account_1',
              'to': 'account_2',
              'amount': 100000000, // 1 ICP in e8s
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }
          ]
        };
      default:
        return {'result': 'success'};
    }
  }

  Map<String, dynamic> _getDefaultUpdateResponse(String method, Map<String, dynamic>? args) {
    switch (method) {
      case 'mint':
        return {'transaction_id': 'tx_mint_${DateTime.now().millisecondsSinceEpoch}'};
      case 'transfer':
        return {'transaction_id': 'tx_transfer_${DateTime.now().millisecondsSinceEpoch}'};
      case 'burn':
        return {'transaction_id': 'tx_burn_${DateTime.now().millisecondsSinceEpoch}'};
      case 'approve':
        return {'transaction_id': 'tx_approve_${DateTime.now().millisecondsSinceEpoch}'};
      case 'update_token_metadata':
        return {'success': true};
      default:
        return {'transaction_id': 'tx_${DateTime.now().millisecondsSinceEpoch}'};
    }
  }
}
