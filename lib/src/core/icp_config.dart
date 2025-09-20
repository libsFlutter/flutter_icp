import 'icp_types.dart';

/// Configuration class for ICP operations
class ICPConfig {
  static ICPConfig? _instance;
  static ICPConfig get instance => _instance ??= ICPConfig._internal();
  
  ICPConfig._internal();

  ICPNetworkConfig _networkConfig = ICPNetworkConfig.mainnet;
  Map<String, String> _canisterIds = {};
  Map<String, dynamic> _customParams = {};

  /// Current network configuration
  ICPNetworkConfig get networkConfig => _networkConfig;

  /// Set network configuration
  void setNetworkConfig(ICPNetworkConfig config) {
    _networkConfig = config;
  }

  /// Switch to mainnet
  void useMainnet() {
    _networkConfig = ICPNetworkConfig.mainnet;
  }

  /// Switch to testnet
  void useTestnet() {
    _networkConfig = ICPNetworkConfig.testnet;
  }

  /// Get canister ID by name
  String? getCanisterId(String name) {
    return _canisterIds[name] ?? _networkConfig.canisterIds[name];
  }

  /// Set custom canister ID
  void setCanisterId(String name, String canisterId) {
    _canisterIds[name] = canisterId;
  }

  /// Get custom parameter
  T? getCustomParam<T>(String key) {
    return _customParams[key] as T?;
  }

  /// Set custom parameter
  void setCustomParam(String key, dynamic value) {
    _customParams[key] = value;
  }

  /// Get all custom parameters
  Map<String, dynamic> get customParams => Map.unmodifiable(_customParams);

  /// Reset configuration to defaults
  void reset() {
    _networkConfig = ICPNetworkConfig.mainnet;
    _canisterIds.clear();
    _customParams.clear();
  }

  /// Get network URL
  String get networkUrl => _networkConfig.url;

  /// Check if using testnet
  bool get isTestnet => _networkConfig.isTestnet;

  /// Check if using mainnet
  bool get isMainnet => !_networkConfig.isTestnet;

  /// Default canister IDs for mainnet
  static const Map<String, String> mainnetCanisters = {
    'ledger': 'ryjl3-tyaaa-aaaaa-aaaba-cai',
    'registry': 'rdmx6-jaaaa-aaaaa-aaadq-cai',
    'governance': 'rrkah-fqaaa-aaaar-aacaq-cai',
    'nns': 'qaa6y-5yaaa-aaaah-aaada-cai',
  };

  /// Default canister IDs for testnet
  static const Map<String, String> testnetCanisters = {
    'ledger': 'ryjl3-tyaaa-aaaaa-aaaba-cai',
    'registry': 'rdmx6-jaaaa-aaaaa-aaadq-cai',
    'governance': 'rrkah-fqaaa-aaaar-aacaq-cai',
    'nns': 'qaa6y-5yaaa-aaaah-aaada-cai',
  };

  /// Common marketplace canister IDs
  static const Map<String, String> marketplaceCanisters = {
    'yuku': 'rdmx6-jaaaa-aaaaa-aaadq-cai', // Example
    'entrepot': 'rdmx6-jaaaa-aaaaa-aaadq-cai', // Example
    'tonic': 'rdmx6-jaaaa-aaaaa-aaadq-cai', // Example
  };

  /// Get marketplace canister ID
  String? getMarketplaceCanisterId(String marketplace) {
    return marketplaceCanisters[marketplace.toLowerCase()];
  }

  /// Transaction fee estimates (in e8s)
  static const Map<ICPTransactionType, double> transactionFees = {
    ICPTransactionType.transfer: 0.0001,
    ICPTransactionType.mint: 0.001,
    ICPTransactionType.burn: 0.001,
    ICPTransactionType.approve: 0.0005,
    ICPTransactionType.list: 0.002,
    ICPTransactionType.buy: 0.003,
    ICPTransactionType.makeOffer: 0.001,
    ICPTransactionType.acceptOffer: 0.002,
    ICPTransactionType.cancelListing: 0.0005,
    ICPTransactionType.cancelOffer: 0.0005,
  };

  /// Get estimated transaction fee
  double getEstimatedFee(ICPTransactionType type) {
    return transactionFees[type] ?? 0.001;
  }

  /// Default transaction timeout (in seconds)
  static const int defaultTransactionTimeout = 60;

  /// Default query timeout (in seconds)
  static const int defaultQueryTimeout = 30;

  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;

  /// Retry delay (in milliseconds)
  static const int retryDelay = 1000;

  /// Enable debug logging
  bool debugLogging = false;

  /// Enable transaction logging
  bool transactionLogging = true;

  /// Enable performance metrics
  bool performanceMetrics = false;

  /// Custom headers for HTTP requests
  Map<String, String> customHeaders = {};

  /// Request timeout (in milliseconds)
  int requestTimeout = 30000;

  /// Enable caching
  bool enableCaching = true;

  /// Cache TTL (in seconds)
  int cacheTtl = 300;

  /// Validate configuration
  bool validate() {
    if (_networkConfig.url.isEmpty) return false;
    if (_networkConfig.name.isEmpty) return false;
    return true;
  }

  /// Get configuration summary
  Map<String, dynamic> getSummary() {
    return {
      'network': _networkConfig.name,
      'url': _networkConfig.url,
      'isTestnet': _networkConfig.isTestnet,
      'canisterIds': _canisterIds,
      'customParams': _customParams,
      'debugLogging': debugLogging,
      'transactionLogging': transactionLogging,
      'performanceMetrics': performanceMetrics,
      'enableCaching': enableCaching,
      'cacheTtl': cacheTtl,
    };
  }
}
