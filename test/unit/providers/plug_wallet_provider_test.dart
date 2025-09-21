import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nft/flutter_nft.dart';
import 'package:flutter_icp/src/providers/plug_wallet_provider.dart';
import 'package:flutter_icp/src/core/icp_exceptions.dart';

void main() {
  group('PlugWalletProvider', () {
    late PlugWalletProvider provider;
    // late MockPlugWalletService mockWalletService;

    setUp(() {
      provider = PlugWalletProvider();
      // mockWalletService = MockPlugWalletService();
    });

    group('Provider Information', () {
      test('should have correct provider details', () {
        // Assert
        expect(provider.id, equals('plug-wallet-provider'));
        expect(provider.name, equals('Plug Wallet Provider'));
        expect(provider.version, equals('1.0.0'));
        expect(provider.network, equals(BlockchainNetwork.icp));
      });
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Act
        await provider.initialize();

        // Assert
        expect(provider.isAvailable, isTrue);
      });

      test('should dispose successfully', () async {
        // Arrange
        await provider.initialize();

        // Act
        await provider.dispose();

        // Assert
        expect(provider.isAvailable, isFalse);
      });
    });

    group('Connection Management', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should connect wallet successfully', () async {
        // Act
        final connected = await provider.connect();

        // Assert
        expect(connected, isTrue);
        expect(provider.isConnected, isTrue);
        expect(provider.connectedAddress, isNotNull);
      });

      test('should disconnect wallet successfully', () async {
        // Arrange
        await provider.connect();

        // Act
        await provider.disconnect();

        // Assert
        expect(provider.isConnected, isFalse);
        expect(provider.connectedAddress, isNull);
      });

      test('should get wallet address when connected', () async {
        // Arrange
        await provider.connect();

        // Act
        final address = await provider.getAddress();

        // Assert
        expect(address, isNotNull);
        expect(address, equals(provider.connectedAddress));
      });

      test('should return null address when not connected', () async {
        // Act
        final address = await provider.getAddress();

        // Assert
        expect(address, isNull);
      });
    });

    group('Balance Operations', () {
      setUp(() async {
        await provider.initialize();
        await provider.connect();
      });

      test('should get balance for specific currency', () async {
        // Arrange
        const currency = 'ICP';

        // Act
        final balance = await provider.getBalance(currency);

        // Assert
        expect(balance, isA<double>());
        expect(balance, greaterThanOrEqualTo(0));
      });

      test('should get balances for multiple currencies', () async {
        // Arrange
        const currencies = ['ICP', 'WICP'];

        // Act
        final balances = await provider.getBalances(currencies);

        // Assert
        expect(balances, isA<Map<String, double>>());
        expect(balances.containsKey('ICP'), isTrue);
        expect(balances.containsKey('WICP'), isTrue);
      });

      test('should throw exception when getting balance while disconnected',
          () async {
        // Arrange
        await provider.disconnect();

        // Act & Assert
        expect(
          () => provider.getBalance('ICP'),
          throwsException,
        );
      });
    });

    group('Transaction Operations', () {
      setUp(() async {
        await provider.initialize();
        await provider.connect();
      });

      test('should send transaction successfully', () async {
        // Arrange
        const to = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const amount = 1.0;
        const currency = 'ICP';
        const memo = 'Test transaction';

        // Act
        final transactionId = await provider.sendTransaction(
          to: to,
          amount: amount,
          currency: currency,
          memo: memo,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_'), isTrue);
      });

      test('should sign message successfully', () async {
        // Arrange
        const message = 'Test message to sign';

        // Act
        final signature = await provider.signMessage(message);

        // Assert
        expect(signature, isA<String>());
        expect(signature.startsWith('signature_'), isTrue);
      });

      test('should sign transaction successfully', () async {
        // Arrange
        final transaction = {
          'canisterId': 'test-canister',
          'method': 'test_method',
          'args': {'param': 'value'},
        };

        // Act
        final transactionId = await provider.signTransaction(transaction);

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_'), isTrue);
      });

      test('should throw exception for invalid transaction parameters',
          () async {
        // Arrange
        final invalidTransaction = {
          'method': 'test_method',
          // Missing canisterId
        };

        // Act & Assert
        expect(
          () => provider.signTransaction(invalidTransaction),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
      });

      test('should get transaction history', () async {
        // Act
        final history =
            await provider.getTransactionHistory(limit: 10, offset: 0);

        // Assert
        expect(history, isA<List<Map<String, dynamic>>>());
      });

      test('should get transaction details', () async {
        // Arrange
        const transactionHash = 'tx_123';

        // Act
        final details = await provider.getTransactionDetails(transactionHash);

        // Assert
        expect(details, isA<Map<String, dynamic>>());
        expect(details.containsKey('id'), isTrue);
      });

      test('should estimate transaction fee', () async {
        // Arrange
        const to = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const amount = 1.0;
        const currency = 'ICP';

        // Act
        final fee = await provider.estimateTransactionFee(
          to: to,
          amount: amount,
          currency: currency,
        );

        // Assert
        expect(fee, isA<double>());
        expect(fee, greaterThanOrEqualTo(0));
      });
    });

    group('Network Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get current network', () async {
        // Act
        final network = await provider.getCurrentNetwork();

        // Assert
        expect(network, isA<NetworkConfig>());
        expect(network.network, equals(BlockchainNetwork.icp));
      });

      test('should get supported networks', () {
        // Act
        final networks = provider.getSupportedNetworks();

        // Assert
        expect(networks, isA<List<NetworkConfig>>());
        expect(networks.isNotEmpty, isTrue);
        expect(networks.any((n) => n.name.contains('Mainnet')), isTrue);
        expect(networks.any((n) => n.name.contains('Testnet')), isTrue);
      });

      test('should switch network successfully', () async {
        // Arrange
        final testnetConfig = NetworkConfig(
          name: 'ICP Testnet',
          rpcUrl: 'https://ic0.testnet.app',
          chainId: '1',
          network: BlockchainNetwork.icp,
          isTestnet: true,
        );

        // Act
        final success = await provider.switchNetwork(testnetConfig);

        // Assert
        expect(success, isTrue);
      });
    });

    group('Wallet Information', () {
      setUp(() async {
        await provider.initialize();
        await provider.connect();
      });

      test('should get wallet info', () async {
        // Act
        final info = await provider.getWalletInfo();

        // Assert
        expect(info, isA<Map<String, dynamic>>());
        expect(info.containsKey('principal'), isTrue);
        expect(info.containsKey('accountId'), isTrue);
        expect(info.containsKey('stats'), isTrue);
      });
    });

    group('Currency Support', () {
      test('should check if currency is supported', () {
        // Act & Assert
        expect(provider.isCurrencySupported('ICP'), isTrue);
        expect(provider.isCurrencySupported('WICP'), isTrue);
        expect(provider.isCurrencySupported('BTC'), isFalse);
      });

      test('should return supported currencies', () {
        // Act
        final currencies = provider.getSupportedCurrencies();

        // Assert
        expect(currencies, isA<List<SupportedCurrency>>());
        expect(currencies.isNotEmpty, isTrue);
        expect(currencies.any((c) => c.symbol == 'ICP'), isTrue);
        expect(currencies.any((c) => c.symbol == 'WICP'), isTrue);
      });
    });

    group('Permissions', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should request permissions successfully', () async {
        // Arrange
        const permissions = ['read_balance', 'send_transaction'];

        // Act
        final granted = await provider.requestPermissions(permissions);

        // Assert
        expect(granted, isTrue);
      });

      test('should check permissions when connected', () async {
        // Arrange
        await provider.connect();
        const permissions = ['read_balance', 'send_transaction'];

        // Act
        final hasPermissions = await provider.hasPermissions(permissions);

        // Assert
        expect(hasPermissions, isTrue);
      });

      test('should check permissions when not connected', () async {
        // Arrange
        const permissions = ['read_balance', 'send_transaction'];

        // Act
        final hasPermissions = await provider.hasPermissions(permissions);

        // Assert
        expect(hasPermissions, isFalse);
      });
    });

    group('ICP-Specific Operations', () {
      setUp(() async {
        await provider.initialize();
        await provider.connect();
      });

      test('should approve NFT transaction', () async {
        // Arrange
        const nftCanisterId = 'test-nft-canister';
        const nftId = 'nft_1';
        const price = 10.0;
        const currency = 'ICP';

        // Act
        final approved = await provider.approveNFTTransaction(
          nftCanisterId: nftCanisterId,
          nftId: nftId,
          price: price,
          currency: currency,
        );

        // Assert
        expect(approved, isTrue);
      });

      test('should approve listing transaction', () async {
        // Arrange
        const marketplaceCanisterId = 'test-marketplace-canister';
        const nftId = 'nft_1';
        const price = 10.0;
        const currency = 'ICP';

        // Act
        final approved = await provider.approveListingTransaction(
          marketplaceCanisterId: marketplaceCanisterId,
          nftId: nftId,
          price: price,
          currency: currency,
        );

        // Assert
        expect(approved, isTrue);
      });

      test('should approve offer transaction', () async {
        // Arrange
        const marketplaceCanisterId = 'test-marketplace-canister';
        const nftId = 'nft_1';
        const amount = 8.0;
        const currency = 'ICP';

        // Act
        final approved = await provider.approveOfferTransaction(
          marketplaceCanisterId: marketplaceCanisterId,
          nftId: nftId,
          amount: amount,
          currency: currency,
        );

        // Assert
        expect(approved, isTrue);
      });
    });

    group('Error Handling', () {
      test('should throw exception when not available', () async {
        // Arrange - don't initialize provider

        // Act & Assert
        expect(
          () => provider.connect(),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
      });

      test('should throw exception when not connected for balance operations',
          () async {
        // Arrange
        await provider.initialize();
        // Don't connect

        // Act & Assert
        expect(
          () => provider.getBalance('ICP'),
          throwsException,
        );
      });

      test(
          'should throw exception when not connected for transaction operations',
          () async {
        // Arrange
        await provider.initialize();
        // Don't connect

        // Act & Assert
        expect(
          () => provider.sendTransaction(
            to: 'test-address',
            amount: 1.0,
            currency: 'ICP',
          ),
          throwsException,
        );
      });
    });

    group('Wallet Service Access', () {
      test('should provide access to wallet service', () {
        // Act
        final walletService = provider.walletService;

        // Assert
        expect(walletService, isNotNull);
      });
    });
  });
}
