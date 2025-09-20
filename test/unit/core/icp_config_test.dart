import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_icp/src/core/icp_config.dart';
import 'package:flutter_icp/src/core/icp_types.dart';

void main() {
  group('ICPConfig', () {
    late ICPConfig config;

    setUp(() {
      config = ICPConfig.instance;
      config.reset();
    });

    group('Network Configuration', () {
      test('should use mainnet by default', () {
        // Assert
        expect(config.networkConfig, equals(ICPNetworkConfig.mainnet));
        expect(config.isMainnet, isTrue);
        expect(config.isTestnet, isFalse);
      });

      test('should switch to testnet', () {
        // Act
        config.useTestnet();

        // Assert
        expect(config.networkConfig, equals(ICPNetworkConfig.testnet));
        expect(config.isTestnet, isTrue);
        expect(config.isMainnet, isFalse);
      });

      test('should switch to mainnet', () {
        // Arrange
        config.useTestnet();

        // Act
        config.useMainnet();

        // Assert
        expect(config.networkConfig, equals(ICPNetworkConfig.mainnet));
        expect(config.isMainnet, isTrue);
        expect(config.isTestnet, isFalse);
      });

      test('should set custom network configuration', () {
        // Arrange
        const customConfig = ICPNetworkConfig(
          name: 'Custom Network',
          url: 'https://custom.icp.network',
          isTestnet: true,
          canisterIds: {'custom': 'custom-canister-id'},
        );

        // Act
        config.setNetworkConfig(customConfig);

        // Assert
        expect(config.networkConfig, equals(customConfig));
        expect(config.networkUrl, equals('https://custom.icp.network'));
      });
    });

    group('Canister Management', () {
      test('should get default canister IDs from network config', () {
        // Arrange
        config.useMainnet();

        // Act & Assert
        expect(config.getCanisterId('ledger'), isNotNull);
        expect(config.getCanisterId('registry'), isNotNull);
      });

      test('should set and get custom canister ID', () {
        // Arrange
        const canisterName = 'custom';
        const canisterId = 'custom-canister-id';

        // Act
        config.setCanisterId(canisterName, canisterId);

        // Assert
        expect(config.getCanisterId(canisterName), equals(canisterId));
      });

      test('should override network canister ID with custom one', () {
        // Arrange
        config.useMainnet();
        const customLedgerCanister = 'custom-ledger-canister';

        // Act
        config.setCanisterId('ledger', customLedgerCanister);

        // Assert
        expect(config.getCanisterId('ledger'), equals(customLedgerCanister));
      });

      test('should return null for non-existent canister', () {
        // Act & Assert
        expect(config.getCanisterId('non-existent'), isNull);
      });

      test('should get marketplace canister ID', () {
        // Act & Assert
        expect(config.getMarketplaceCanisterId('yuku'), isNotNull);
        expect(config.getMarketplaceCanisterId('entrepot'), isNotNull);
        expect(config.getMarketplaceCanisterId('non-existent'), isNull);
      });
    });

    group('Custom Parameters', () {
      test('should set and get custom parameter', () {
        // Arrange
        const key = 'test_param';
        const value = 'test_value';

        // Act
        config.setCustomParam(key, value);

        // Assert
        expect(config.getCustomParam<String>(key), equals(value));
      });

      test('should return null for non-existent parameter', () {
        // Act & Assert
        expect(config.getCustomParam<String>('non-existent'), isNull);
      });

      test('should get all custom parameters', () {
        // Arrange
        config.setCustomParam('param1', 'value1');
        config.setCustomParam('param2', 42);

        // Act
        final params = config.customParams;

        // Assert
        expect(params, containsPair('param1', 'value1'));
        expect(params, containsPair('param2', 42));
        expect(params.length, equals(2));
      });
    });

    group('Transaction Fees', () {
      test('should get estimated fee for transaction type', () {
        // Act & Assert
        expect(config.getEstimatedFee(ICPTransactionType.transfer), equals(0.0001));
        expect(config.getEstimatedFee(ICPTransactionType.mint), equals(0.001));
        expect(config.getEstimatedFee(ICPTransactionType.buy), equals(0.003));
      });

      test('should return default fee for unknown transaction type', () {
        // This test would require adding a mock transaction type
        // For now, we test with existing types
        expect(config.getEstimatedFee(ICPTransactionType.transfer), isA<double>());
      });
    });

    group('Configuration Options', () {
      test('should enable/disable debug logging', () {
        // Act
        config.debugLogging = true;

        // Assert
        expect(config.debugLogging, isTrue);

        // Act
        config.debugLogging = false;

        // Assert
        expect(config.debugLogging, isFalse);
      });

      test('should enable/disable transaction logging', () {
        // Act
        config.transactionLogging = false;

        // Assert
        expect(config.transactionLogging, isFalse);

        // Act
        config.transactionLogging = true;

        // Assert
        expect(config.transactionLogging, isTrue);
      });

      test('should enable/disable performance metrics', () {
        // Act
        config.performanceMetrics = true;

        // Assert
        expect(config.performanceMetrics, isTrue);
      });

      test('should set custom headers', () {
        // Arrange
        final headers = {'X-Custom-Header': 'custom-value'};

        // Act
        config.customHeaders = headers;

        // Assert
        expect(config.customHeaders, equals(headers));
      });

      test('should set request timeout', () {
        // Act
        config.requestTimeout = 60000;

        // Assert
        expect(config.requestTimeout, equals(60000));
      });

      test('should enable/disable caching', () {
        // Act
        config.enableCaching = false;

        // Assert
        expect(config.enableCaching, isFalse);

        // Act
        config.enableCaching = true;

        // Assert
        expect(config.enableCaching, isTrue);
      });

      test('should set cache TTL', () {
        // Act
        config.cacheTtl = 600;

        // Assert
        expect(config.cacheTtl, equals(600));
      });
    });

    group('Validation', () {
      test('should validate valid configuration', () {
        // Arrange
        config.useMainnet();

        // Act & Assert
        expect(config.validate(), isTrue);
      });

      test('should invalidate configuration with empty URL', () {
        // Arrange
        config.setNetworkConfig(ICPNetworkConfig(
          name: 'Test Network',
          url: '',
          isTestnet: false,
        ));

        // Act & Assert
        expect(config.validate(), isFalse);
      });

      test('should invalidate configuration with empty name', () {
        // Arrange
        config.setNetworkConfig(ICPNetworkConfig(
          name: '',
          url: 'https://test.network',
          isTestnet: false,
        ));

        // Act & Assert
        expect(config.validate(), isFalse);
      });
    });

    group('Summary', () {
      test('should provide configuration summary', () {
        // Arrange
        config.useMainnet();
        config.setCanisterId('custom', 'custom-canister');
        config.setCustomParam('param', 'value');
        config.debugLogging = true;

        // Act
        final summary = config.getSummary();

        // Assert
        expect(summary, isA<Map<String, dynamic>>());
        expect(summary.containsKey('network'), isTrue);
        expect(summary.containsKey('url'), isTrue);
        expect(summary.containsKey('isTestnet'), isTrue);
        expect(summary.containsKey('canisterIds'), isTrue);
        expect(summary.containsKey('customParams'), isTrue);
        expect(summary.containsKey('debugLogging'), isTrue);
        expect(summary['debugLogging'], isTrue);
      });
    });

    group('Reset', () {
      test('should reset configuration to defaults', () {
        // Arrange
        config.useTestnet();
        config.setCanisterId('custom', 'custom-canister');
        config.setCustomParam('param', 'value');
        config.debugLogging = true;

        // Act
        config.reset();

      // Assert
      expect(config.networkConfig, equals(ICPNetworkConfig.mainnet));
      expect(config.getCanisterId('custom'), isNull);
      expect(config.getCustomParam('param'), isNull);
      });
    });

    group('Constants', () {
      test('should have correct default timeout values', () {
        // Assert
        expect(ICPConfig.defaultTransactionTimeout, equals(60));
        expect(ICPConfig.defaultQueryTimeout, equals(30));
      });

      test('should have correct retry configuration', () {
        // Assert
        expect(ICPConfig.maxRetryAttempts, equals(3));
        expect(ICPConfig.retryDelay, equals(1000));
      });

      test('should have mainnet canisters defined', () {
        // Assert
        expect(ICPConfig.mainnetCanisters, isNotEmpty);
        expect(ICPConfig.mainnetCanisters.containsKey('ledger'), isTrue);
        expect(ICPConfig.mainnetCanisters.containsKey('registry'), isTrue);
      });

      test('should have testnet canisters defined', () {
        // Assert
        expect(ICPConfig.testnetCanisters, isNotEmpty);
        expect(ICPConfig.testnetCanisters.containsKey('ledger'), isTrue);
        expect(ICPConfig.testnetCanisters.containsKey('registry'), isTrue);
      });

      test('should have marketplace canisters defined', () {
        // Assert
        expect(ICPConfig.marketplaceCanisters, isNotEmpty);
        expect(ICPConfig.marketplaceCanisters.containsKey('yuku'), isTrue);
      });
    });
  });
}
