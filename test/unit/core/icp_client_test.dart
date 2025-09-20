import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_icp/src/core/icp_client.dart';
import 'package:flutter_icp/src/core/icp_config.dart';
import 'package:flutter_icp/src/core/icp_exceptions.dart';
import 'package:flutter_icp/src/core/icp_types.dart';

void main() {
  group('ICPClient', () {
    late ICPClient client;
    late ICPConfig config;

    setUp(() {
      client = ICPClient.instance;
      config = ICPConfig.instance;
      config.reset();
    });

    tearDown(() {
      config.reset();
    });

    group('Initialization', () {
      test('should have correct default state', () {
        // Assert
        expect(client.isInitialized, isFalse);
        expect(config.isMainnet, isTrue);
        expect(config.networkConfig, equals(ICPNetworkConfig.mainnet));
      });

      test('should throw exception with invalid config', () async {
        // Arrange
        config.setNetworkConfig(ICPNetworkConfig(
          name: '',
          url: '',
          isTestnet: false,
        ));

        // Act & Assert
        expect(
          () => client.initialize(),
          throwsA(isA<ICPConfigurationException>()),
        );
      });
    });

    group('Client Properties', () {
      test('should return correct network config', () {
        // Arrange
        config.useTestnet();

        // Act
        final networkConfig = client.networkConfig;

        // Assert
        expect(networkConfig, equals(ICPNetworkConfig.testnet));
        expect(networkConfig.isTestnet, isTrue);
      });

      test('should provide client statistics', () {
        // Act
        final stats = client.getStats();

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('initialized'), isTrue);
        expect(stats.containsKey('network'), isTrue);
        expect(stats.containsKey('cache'), isTrue);
      });
    });

    group('Cache Management', () {
      test('should clear cache successfully', () {
        // Act
        client.clearCache();
        final stats = client.getCacheStats();

        // Assert
        expect(stats['entries'], equals(0));
        expect(stats.containsKey('enabled'), isTrue);
        expect(stats.containsKey('ttl'), isTrue);
      });

      test('should return cache statistics', () {
        // Act
        final cacheStats = client.getCacheStats();

        // Assert
        expect(cacheStats, isA<Map<String, dynamic>>());
        expect(cacheStats.containsKey('entries'), isTrue);
        expect(cacheStats.containsKey('enabled'), isTrue);
        expect(cacheStats.containsKey('ttl'), isTrue);
      });
    });

    group('Error Handling', () {
      test('should throw exception when not initialized for operations', () {
        // Act & Assert
        expect(
          () => client.query(canisterId: 'test', method: 'test'),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );

        expect(
          () => client.update(canisterId: 'test', method: 'test'),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );

        expect(
          () => client.getCanisterInfo('test'),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );

        expect(
          () => client.getBalance('test'),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
      });
    });
  });
}