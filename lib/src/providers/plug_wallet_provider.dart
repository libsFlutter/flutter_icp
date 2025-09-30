import 'package:flutter_yuku/flutter_yuku.dart';
import '../core/icp_client.dart';
import '../core/icp_config.dart';
import '../core/icp_types.dart';
import '../core/icp_exceptions.dart';
import '../services/plug_wallet_service.dart';

/// ICP implementation of WalletProvider for flutter_yuku
class PlugWalletProvider implements WalletProvider {
  final ICPClient _client = ICPClient.instance;
  final ICPConfig _config = ICPConfig.instance;
  final PlugWalletService _walletService = PlugWalletService();
  bool _isAvailable = false;

  @override
  String get id => 'plug-wallet-provider';

  @override
  String get name => 'Plug Wallet Provider';

  @override
  String get version => '1.0.0';

  @override
  BlockchainNetwork get network => BlockchainNetwork.icp;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isConnected => _walletService.isConnected;

  @override
  String? get connectedAddress => _walletService.principalId;

  @override
  Future<void> initialize() async {
    try {
      await _client.initialize();
      await _walletService.initialize();
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      throw ICPServiceNotInitializedException(
        'Failed to initialize Plug Wallet provider: $e',
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _walletService.disconnect();
    _isAvailable = false;
  }

  @override
  Future<bool> connect() async {
    _ensureAvailable();
    return await _walletService.connect();
  }

  @override
  Future<void> disconnect() async {
    _ensureAvailable();
    await _walletService.disconnect();
  }

  @override
  Future<String?> getAddress() async {
    _ensureAvailable();
    return _walletService.principalId;
  }

  @override
  Future<double> getBalance(String currency) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final balances = await _walletService.getBalance();
      return balances[currency] ?? 0.0;
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to get balance for $currency: $e',
      );
    }
  }

  @override
  Future<Map<String, double>> getBalances(List<String> currencies) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final allBalances = await _walletService.getBalance();
      final requestedBalances = <String, double>{};

      for (final currency in currencies) {
        requestedBalances[currency] = allBalances[currency] ?? 0.0;
      }

      return requestedBalances;
    } catch (e) {
      throw ICPServiceNotInitializedException('Failed to get balances: $e');
    }
  }

  @override
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required String currency,
    String? memo,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final success = await _walletService.sendTransaction(
        to: to,
        amount: amount,
        currency: currency,
        memo: memo,
      );

      if (!success) {
        throw ICPTransactionException('Transaction failed');
      }

      // Return a mock transaction ID - in real implementation, this would come from the service
      return 'tx_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw ICPTransactionException('Failed to send transaction: $e');
    }
  }

  @override
  Future<String> signMessage(String message) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final success = await _walletService.signMessage(message);

      if (!success) {
        throw ICPServiceNotInitializedException('Failed to sign message');
      }

      // Return a mock signature - in real implementation, this would come from the service
      return 'signature_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw ICPServiceNotInitializedException('Failed to sign message: $e');
    }
  }

  @override
  Future<String> signTransaction(Map<String, dynamic> transaction) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final canisterId = transaction['canisterId'] as String?;
      final method = transaction['method'] as String?;
      final args = transaction['args'] as Map<String, dynamic>?;

      if (canisterId == null || method == null) {
        throw ICPServiceNotInitializedException(
          'Invalid transaction parameters',
        );
      }

      final success = await _walletService.approveTransaction(
        canisterId: canisterId,
        method: method,
        args: args ?? {},
      );

      if (!success) {
        throw ICPTransactionException('Transaction approval failed');
      }

      // Return a mock transaction ID
      return 'tx_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw ICPTransactionException('Failed to sign transaction: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int? limit,
    int? offset,
  }) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final history = await _walletService.getTransactionHistory();

      // Apply limit and offset
      final startIndex = offset ?? 0;
      final endIndex = limit != null ? startIndex + limit : history.length;

      return history.sublist(
        startIndex.clamp(0, history.length),
        endIndex.clamp(0, history.length),
      );
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to get transaction history: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionDetails(
    String transactionHash,
  ) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      return await _walletService.getTransactionDetails(transactionHash);
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to get transaction details: $e',
      );
    }
  }

  @override
  Future<double> estimateTransactionFee({
    required String to,
    required double amount,
    required String currency,
  }) async {
    _ensureAvailable();

    try {
      // Use ICP config to get estimated fee
      return _config.getEstimatedFee(ICPTransactionType.transfer);
    } catch (e) {
      return 0.0001; // Default fee
    }
  }

  @override
  Future<bool> switchNetwork(NetworkConfig networkConfig) async {
    _ensureAvailable();

    try {
      final icpConfig = ICPNetworkConfig(
        name: networkConfig.name,
        url: networkConfig.rpcUrl,
        isTestnet: networkConfig.isTestnet,
        canisterIds: networkConfig.additionalParams.cast<String, String>(),
      );

      _config.setNetworkConfig(icpConfig);
      await _client.dispose();
      await _client.initialize();

      return true;
    } catch (e) {
      throw ICPServiceNotInitializedException('Failed to switch network: $e');
    }
  }

  @override
  Future<NetworkConfig> getCurrentNetwork() async {
    _ensureAvailable();

    final icpConfig = _config.networkConfig;
    return NetworkConfig(
      name: icpConfig.name,
      rpcUrl: icpConfig.url,
      chainId: '1', // ICP doesn't use chain IDs like Ethereum
      network: BlockchainNetwork.icp,
      isTestnet: icpConfig.isTestnet,
      additionalParams: icpConfig.canisterIds,
    );
  }

  @override
  List<NetworkConfig> getSupportedNetworks() {
    return [
      NetworkConfig(
        name: 'ICP Mainnet',
        rpcUrl: 'https://ic0.app',
        chainId: '1',
        network: BlockchainNetwork.icp,
        isTestnet: false,
        additionalParams: ICPConfig.mainnetCanisters,
      ),
      NetworkConfig(
        name: 'ICP Testnet',
        rpcUrl: 'https://ic0.testnet.app',
        chainId: '1',
        network: BlockchainNetwork.icp,
        isTestnet: true,
        additionalParams: ICPConfig.testnetCanisters,
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> getWalletInfo() async {
    _ensureAvailable();
    _ensureConnected();

    try {
      final stats = await _walletService.getWalletStats();
      return {
        'principal': _walletService.principalId,
        'accountId': _walletService.accountId,
        'stats': stats,
        'network': _config.networkConfig.name,
        'isTestnet': _config.networkConfig.isTestnet,
      };
    } catch (e) {
      throw ICPServiceNotInitializedException('Failed to get wallet info: $e');
    }
  }

  @override
  bool isCurrencySupported(String currency) {
    return getSupportedCurrencies().any((c) => c.symbol == currency);
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
  Future<bool> requestPermissions(List<String> permissions) async {
    _ensureAvailable();

    // Plug Wallet doesn't require specific permissions like some other wallets
    // The connection process handles the necessary permissions
    return true;
  }

  @override
  Future<bool> hasPermissions(List<String> permissions) async {
    _ensureAvailable();

    // If connected, assume we have the necessary permissions
    return isConnected;
  }

  /// Get wallet service instance for advanced operations
  PlugWalletService get walletService => _walletService;

  /// Approve NFT transaction (specific to ICP)
  Future<bool> approveNFTTransaction({
    required String nftCanisterId,
    required String nftId,
    required double price,
    required String currency,
  }) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      return await _walletService.approveNFTTransaction(
        nftCanisterId: nftCanisterId,
        nftId: nftId,
        price: price,
        currency: currency,
      );
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to approve NFT transaction: $e',
      );
    }
  }

  /// Approve listing transaction (specific to ICP)
  Future<bool> approveListingTransaction({
    required String marketplaceCanisterId,
    required String nftId,
    required double price,
    required String currency,
  }) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      return await _walletService.approveListingTransaction(
        marketplaceCanisterId: marketplaceCanisterId,
        nftId: nftId,
        price: price,
        currency: currency,
      );
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to approve listing transaction: $e',
      );
    }
  }

  /// Approve offer transaction (specific to ICP)
  Future<bool> approveOfferTransaction({
    required String marketplaceCanisterId,
    required String nftId,
    required double amount,
    required String currency,
  }) async {
    _ensureAvailable();
    _ensureConnected();

    try {
      return await _walletService.approveOfferTransaction(
        marketplaceCanisterId: marketplaceCanisterId,
        nftId: nftId,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      throw ICPServiceNotInitializedException(
        'Failed to approve offer transaction: $e',
      );
    }
  }

  /// Ensure provider is available
  void _ensureAvailable() {
    if (!_isAvailable) {
      throw ICPServiceNotInitializedException(
        'Plug Wallet provider is not available',
      );
    }
  }

  /// Ensure wallet is connected
  void _ensureConnected() {
    if (!isConnected) {
      throw WalletNotConnectedException('Wallet is not connected');
    }
  }
}
