import 'package:flutter_nft/flutter_nft.dart';
import '../core/icp_client.dart';
import '../core/icp_config.dart';
import '../core/icp_types.dart';
import '../core/icp_exceptions.dart';
import '../models/icp_nft.dart';

/// ICP implementation of NFTProvider for flutter_nft
class ICPNFTProvider implements NFTProvider {
  final ICPClient _client = ICPClient.instance;
  final ICPConfig _config = ICPConfig.instance;
  bool _isAvailable = false;

  @override
  String get id => 'icp-nft-provider';

  @override
  String get name => 'Internet Computer NFT Provider';

  @override
  String get version => '1.0.0';

  @override
  BlockchainNetwork get network => BlockchainNetwork.icp;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<void> initialize() async {
    try {
      await _client.initialize();
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      throw ICPServiceNotInitializedException(
          'Failed to initialize ICP NFT provider: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _client.dispose();
    _isAvailable = false;
  }

  @override
  Future<List<NFT>> getNFTsByOwner(String ownerAddress) async {
    _ensureAvailable();

    try {
      // Convert to ICP format
      final icpPrincipal = ICPPrincipal(value: ownerAddress);
      if (!icpPrincipal.isValid) {
        throw ICPPrincipalInvalidException(
            'Invalid ICP principal: $ownerAddress');
      }

      // Get NFTs from ICP canister
      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.query(
        canisterId: nftCanisterId,
        method: 'get_tokens_by_owner',
        args: {'owner': ownerAddress},
      );

      final tokens = List<Map<String, dynamic>>.from(result['tokens'] ?? []);
      final nfts = <NFT>[];

      for (final tokenData in tokens) {
        final icpNft = ICPNFT.fromJson(tokenData);
        nfts.add(_convertICPToNFT(icpNft));
      }

      return nfts;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to get NFTs by owner: $e');
    }
  }

  @override
  Future<NFT?> getNFT(String tokenId, String contractAddress) async {
    _ensureAvailable();

    try {
      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.query(
        canisterId: nftCanisterId,
        method: 'get_token',
        args: {'token_id': tokenId},
      );

      if (result['token'] == null) {
        return null;
      }

      final icpNft = ICPNFT.fromJson(result['token']);
      return _convertICPToNFT(icpNft);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to get NFT: $e');
    }
  }

  @override
  Future<List<NFT>> getNFTs(
      List<String> tokenIds, String contractAddress) async {
    _ensureAvailable();

    try {
      final nfts = <NFT>[];

      for (final tokenId in tokenIds) {
        final nft = await getNFT(tokenId, contractAddress);
        if (nft != null) {
          nfts.add(nft);
        }
      }

      return nfts;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to get NFTs: $e');
    }
  }

  @override
  Future<String> mintNFT({
    required String toAddress,
    required NFTMetadata metadata,
    required String contractAddress,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final icpPrincipal = ICPPrincipal(value: toAddress);
      if (!icpPrincipal.isValid) {
        throw ICPPrincipalInvalidException('Invalid ICP principal: $toAddress');
      }

      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.update(
        canisterId: nftCanisterId,
        method: 'mint',
        args: {
          'to': toAddress,
          'metadata': metadata.toJson(),
          ...?additionalParams,
        },
      );

      return result['transaction_id'] as String;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to mint NFT: $e');
    }
  }

  @override
  Future<String> transferNFT({
    required String tokenId,
    required String fromAddress,
    required String toAddress,
    required String contractAddress,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final fromPrincipal = ICPPrincipal(value: fromAddress);
      final toPrincipal = ICPPrincipal(value: toAddress);

      if (!fromPrincipal.isValid || !toPrincipal.isValid) {
        throw ICPPrincipalInvalidException('Invalid ICP principals');
      }

      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.update(
        canisterId: nftCanisterId,
        method: 'transfer',
        args: {
          'token_id': tokenId,
          'from': fromAddress,
          'to': toAddress,
          ...?additionalParams,
        },
      );

      return result['transaction_id'] as String;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to transfer NFT: $e');
    }
  }

  @override
  Future<String> burnNFT({
    required String tokenId,
    required String ownerAddress,
    required String contractAddress,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final principal = ICPPrincipal(value: ownerAddress);
      if (!principal.isValid) {
        throw ICPPrincipalInvalidException(
            'Invalid ICP principal: $ownerAddress');
      }

      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.update(
        canisterId: nftCanisterId,
        method: 'burn',
        args: {
          'token_id': tokenId,
          'owner': ownerAddress,
          ...?additionalParams,
        },
      );

      return result['transaction_id'] as String;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to burn NFT: $e');
    }
  }

  @override
  Future<String> approveNFT({
    required String tokenId,
    required String ownerAddress,
    required String approvedAddress,
    required String contractAddress,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final ownerPrincipal = ICPPrincipal(value: ownerAddress);
      final approvedPrincipal = ICPPrincipal(value: approvedAddress);

      if (!ownerPrincipal.isValid || !approvedPrincipal.isValid) {
        throw ICPPrincipalInvalidException('Invalid ICP principals');
      }

      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.update(
        canisterId: nftCanisterId,
        method: 'approve',
        args: {
          'token_id': tokenId,
          'owner': ownerAddress,
          'approved': approvedAddress,
          ...?additionalParams,
        },
      );

      return result['transaction_id'] as String;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to approve NFT: $e');
    }
  }

  @override
  Future<bool> isApproved({
    required String tokenId,
    required String ownerAddress,
    required String approvedAddress,
    required String contractAddress,
  }) async {
    _ensureAvailable();

    try {
      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.query(
        canisterId: nftCanisterId,
        method: 'is_approved',
        args: {
          'token_id': tokenId,
          'owner': ownerAddress,
          'approved': approvedAddress,
        },
      );

      return result['approved'] as bool? ?? false;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to check approval: $e');
    }
  }

  @override
  Future<NFTMetadata> getNFTMetadata({
    required String tokenId,
    required String contractAddress,
  }) async {
    _ensureAvailable();

    try {
      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.query(
        canisterId: nftCanisterId,
        method: 'get_token_metadata',
        args: {'token_id': tokenId},
      );

      return NFTMetadata.fromJson(result['metadata']);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to get NFT metadata: $e');
    }
  }

  @override
  Future<bool> updateNFTMetadata({
    required String tokenId,
    required String ownerAddress,
    required NFTMetadata metadata,
    required String contractAddress,
  }) async {
    _ensureAvailable();

    try {
      final principal = ICPPrincipal(value: ownerAddress);
      if (!principal.isValid) {
        throw ICPPrincipalInvalidException(
            'Invalid ICP principal: $ownerAddress');
      }

      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.update(
        canisterId: nftCanisterId,
        method: 'update_token_metadata',
        args: {
          'token_id': tokenId,
          'owner': ownerAddress,
          'metadata': metadata.toJson(),
        },
      );

      return result['success'] as bool? ?? false;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to update NFT metadata: $e');
    }
  }

  @override
  List<SupportedCurrency> getSupportedCurrencies() {
    return [
      const SupportedCurrency(
        symbol: 'ICP',
        name: 'Internet Computer Protocol',
        contractAddress: '',
        decimals: 8,
        network: BlockchainNetwork.icp,
      ),
      const SupportedCurrency(
        symbol: 'WICP',
        name: 'Wrapped ICP',
        contractAddress: '',
        decimals: 8,
        network: BlockchainNetwork.icp,
      ),
    ];
  }

  @override
  Future<double> estimateTransactionFee({
    required String operation,
    required Map<String, dynamic> params,
  }) async {
    _ensureAvailable();

    try {
      final operationType = ICPTransactionType.values.firstWhere(
        (type) => type.name == operation,
        orElse: () => ICPTransactionType.transfer,
      );

      return _config.getEstimatedFee(operationType);
    } catch (e) {
      return 0.001; // Default fee
    }
  }

  @override
  Future<TransactionStatus> getTransactionStatus(String transactionHash) async {
    _ensureAvailable();

    try {
      final ledgerCanisterId = _config.getCanisterId('ledger');
      if (ledgerCanisterId == null) {
        throw ICPConfigurationException('Ledger canister ID not configured');
      }

      final result = await _client.query(
        canisterId: ledgerCanisterId,
        method: 'get_transaction_status',
        args: {'transaction_id': transactionHash},
      );

      final status = result['status'] as String? ?? 'unknown';

      switch (status.toLowerCase()) {
        case 'completed':
        case 'confirmed':
          return TransactionStatus.confirmed;
        case 'pending':
          return TransactionStatus.pending;
        case 'failed':
        case 'error':
          return TransactionStatus.failed;
        case 'cancelled':
          return TransactionStatus.cancelled;
        default:
          return TransactionStatus.pending;
      }
    } catch (e) {
      return TransactionStatus.pending;
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionDetails(
      String transactionHash) async {
    _ensureAvailable();

    try {
      final ledgerCanisterId = _config.getCanisterId('ledger');
      if (ledgerCanisterId == null) {
        throw ICPConfigurationException('Ledger canister ID not configured');
      }

      return await _client.query(
        canisterId: ledgerCanisterId,
        method: 'get_transaction',
        args: {'transaction_id': transactionHash},
      );
    } catch (e) {
      throw NFTOperationException('Failed to get transaction details: $e');
    }
  }

  @override
  Future<List<NFT>> searchNFTs({
    String? name,
    String? description,
    Map<String, dynamic>? attributes,
    String? contractAddress,
    int? limit,
    int? offset,
  }) async {
    _ensureAvailable();

    try {
      final nftCanisterId = _config.getCanisterId('nft');
      if (nftCanisterId == null) {
        throw ICPConfigurationException('NFT canister ID not configured');
      }

      final result = await _client.query(
        canisterId: nftCanisterId,
        method: 'search_tokens',
        args: {
          'name': name,
          'description': description,
          'attributes': attributes,
          'contract_address': contractAddress,
          'limit': limit ?? 50,
          'offset': offset ?? 0,
        },
      );

      final tokens = List<Map<String, dynamic>>.from(result['tokens'] ?? []);
      final nfts = <NFT>[];

      for (final tokenData in tokens) {
        final icpNft = ICPNFT.fromJson(tokenData);
        nfts.add(_convertICPToNFT(icpNft));
      }

      return nfts;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to search NFTs: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getContractInfo(String contractAddress) async {
    _ensureAvailable();

    try {
      return await _client.getCanisterInfo(contractAddress);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw NFTOperationException('Failed to get contract info: $e');
    }
  }

  @override
  Future<bool> isValidContract(String contractAddress) async {
    _ensureAvailable();

    try {
      await _client.getCanisterInfo(contractAddress);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert ICP NFT to universal NFT format
  NFT _convertICPToNFT(ICPNFT icpNft) {
    return NFT(
      id: icpNft.id,
      tokenId: icpNft.tokenId,
      contractAddress: icpNft.canisterId,
      network: BlockchainNetwork.icp,
      metadata: NFTMetadata(
        name: icpNft.metadata.name,
        description: icpNft.metadata.description,
        image: icpNft.metadata.image,
        attributes: icpNft.metadata.attributes,
        properties: icpNft.metadata.properties,
      ),
      owner: icpNft.owner,
      creator: icpNft.creator,
      createdAt: icpNft.createdAt,
      updatedAt: icpNft.updatedAt,
      status: icpNft.status,
      currentValue: icpNft.currentValue,
      valueCurrency: icpNft.valueCurrency,
      transactionHistory: icpNft.transactionHistory,
      additionalProperties: icpNft.additionalProperties,
    );
  }

  /// Ensure provider is available
  void _ensureAvailable() {
    if (!_isAvailable) {
      throw ICPServiceNotInitializedException(
          'ICP NFT provider is not available');
    }
  }
}
