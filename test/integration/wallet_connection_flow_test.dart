import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nft/flutter_nft.dart' hide WalletNotConnectedException;
import 'package:flutter_icp/flutter_icp.dart';

void main() {
  group('Wallet Connection Flow Integration Tests', () {
    late NFTClient nftClient;
    late ICPNFTProvider nftProvider;
    late PlugWalletProvider walletProvider;
    late YukuMarketplaceProvider marketplaceProvider;
    // late MockPlugWalletService mockWalletService;

    setUp(() async {
      // Initialize NFT client
      nftClient = NFTClient();

      // Create providers
      nftProvider = ICPNFTProvider();
      walletProvider = PlugWalletProvider();
      marketplaceProvider = YukuMarketplaceProvider();

      // Set up mock service
      // mockWalletService = MockPlugWalletService();

      // Register providers
      nftClient.registerNFTProvider(nftProvider);
      nftClient.registerWalletProvider(walletProvider);
      nftClient.registerMarketplaceProvider(marketplaceProvider);
    });

    testWidgets('Complete wallet connection and NFT loading flow',
        (WidgetTester tester) async {
      // Test the complete flow as demonstrated in the example app

      // Step 1: Initialize all providers
      await nftClient.initialize();

      expect(nftProvider.isAvailable, isTrue);
      expect(walletProvider.isAvailable, isTrue);
      expect(marketplaceProvider.isAvailable, isTrue);

      // Step 2: Get providers
      final retrievedWalletProvider =
          nftClient.getWalletProvider(BlockchainNetwork.icp);
      final retrievedNftProvider =
          nftClient.getNFTProvider(BlockchainNetwork.icp);
      final retrievedMarketplaceProvider =
          nftClient.getMarketplaceProvider(BlockchainNetwork.icp);

      expect(retrievedWalletProvider, isNotNull);
      expect(retrievedNftProvider, isNotNull);
      expect(retrievedMarketplaceProvider, isNotNull);

      // Step 3: Check initial connection status
      expect(walletProvider.isConnected, isFalse);
      expect(walletProvider.connectedAddress, isNull);

      // Step 4: Connect wallet
      final connected = await walletProvider.connect();
      expect(connected, isTrue);
      expect(walletProvider.isConnected, isTrue);
      expect(walletProvider.connectedAddress, isNotNull);

      // Step 5: Load user NFTs
      final userAddress = walletProvider.connectedAddress!;
      final userNFTs = await nftProvider.getNFTsByOwner(userAddress);
      expect(userNFTs, isA<List<NFT>>());

      // Step 6: Load active listings
      final activeListings = await marketplaceProvider.getActiveListings();
      expect(activeListings, isA<List<NFTListing>>());

      // Step 7: Disconnect wallet
      await walletProvider.disconnect();
      expect(walletProvider.isConnected, isFalse);
      expect(walletProvider.connectedAddress, isNull);
    });

    testWidgets('NFT minting flow', (WidgetTester tester) async {
      // Initialize and connect
      await nftClient.initialize();
      await walletProvider.connect();

      final userAddress = walletProvider.connectedAddress!;

      // Create NFT metadata as in example
      final metadata = NFTMetadata(
        name: 'My ICP NFT #${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test NFT minted on ICP',
        image: 'https://via.placeholder.com/300x300.png?text=ICP+NFT',
        attributes: {
          'Color': 'Blue',
          'Rarity': 'Common',
          'Network': 'ICP',
        },
        properties: {
          'minted_by': 'Flutter ICP Example',
          'mint_date': DateTime.now().toIso8601String(),
        },
      );

      // Mint NFT
      final transactionHash = await nftProvider.mintNFT(
        toAddress: userAddress,
        metadata: metadata,
        contractAddress: 'example-nft-canister-id',
      );

      expect(transactionHash, isA<String>());
      expect(transactionHash.isNotEmpty, isTrue);

      // Verify NFT was minted by loading user NFTs again
      final userNFTsAfterMint = await nftProvider.getNFTsByOwner(userAddress);
      expect(userNFTsAfterMint, isA<List<NFT>>());
    });

    testWidgets('Marketplace listing creation flow',
        (WidgetTester tester) async {
      // Initialize and connect
      await nftClient.initialize();
      await walletProvider.connect();

      final userAddress = walletProvider.connectedAddress!;

      // Get user NFTs
      final userNFTs = await nftProvider.getNFTsByOwner(userAddress);
      expect(userNFTs.isNotEmpty, isTrue);

      final nftToList = userNFTs.first;

      // Create listing as in example
      final listingId = await marketplaceProvider.createListing(
        nftId: nftToList.tokenId,
        contractAddress: nftToList.contractAddress,
        price: 10.0,
        currency: 'ICP',
        sellerAddress: userAddress,
      );

      expect(listingId, isA<String>());
      expect(listingId.isNotEmpty, isTrue);

      // Verify listing was created
      final activeListings = await marketplaceProvider.getActiveListings();
      expect(activeListings, isA<List<NFTListing>>());

      // Check user listings
      final userListings =
          await marketplaceProvider.getUserListings(userAddress);
      expect(userListings, isA<List<NFTListing>>());
    });

    testWidgets('Balance checking flow', (WidgetTester tester) async {
      // Initialize and connect
      await nftClient.initialize();
      await walletProvider.connect();

      // Check ICP balance
      final icpBalance = await walletProvider.getBalance('ICP');
      expect(icpBalance, isA<double>());
      expect(icpBalance, greaterThanOrEqualTo(0));

      // Check multiple balances
      final balances = await walletProvider.getBalances(['ICP', 'WICP']);
      expect(balances, isA<Map<String, double>>());
      expect(balances.containsKey('ICP'), isTrue);
      expect(balances.containsKey('WICP'), isTrue);
    });

    testWidgets('Transaction history flow', (WidgetTester tester) async {
      // Initialize and connect
      await nftClient.initialize();
      await walletProvider.connect();

      // Get transaction history
      final history = await walletProvider.getTransactionHistory(limit: 10);
      expect(history, isA<List<Map<String, dynamic>>>());

      // Get wallet info
      final walletInfo = await walletProvider.getWalletInfo();
      expect(walletInfo, isA<Map<String, dynamic>>());
      expect(walletInfo.containsKey('principal'), isTrue);
      expect(walletInfo.containsKey('accountId'), isTrue);
    });

    testWidgets('Error handling flow', (WidgetTester tester) async {
      // Test operations without initialization
      expect(
        () => walletProvider.connect(),
        throwsA(isA<ICPServiceNotInitializedException>()),
      );

      // Initialize but don't connect
      await nftClient.initialize();

      // Test operations without connection
      expect(
        () => walletProvider.getBalance('ICP'),
        throwsA(isA<WalletNotConnectedException>()),
      );

      // Test invalid operations
      await walletProvider.connect();

      expect(
        () => nftProvider.getNFTsByOwner('invalid-principal'),
        throwsA(isA<ICPPrincipalInvalidException>()),
      );
    });

    testWidgets('Network switching flow', (WidgetTester tester) async {
      // Initialize
      await nftClient.initialize();

      // Get current network
      final currentNetwork = await walletProvider.getCurrentNetwork();
      expect(currentNetwork, isA<NetworkConfig>());
      expect(currentNetwork.network, equals(BlockchainNetwork.icp));

      // Get supported networks
      final supportedNetworks = walletProvider.getSupportedNetworks();
      expect(supportedNetworks, isA<List<NetworkConfig>>());
      expect(supportedNetworks.isNotEmpty, isTrue);

      // Switch to testnet
      final testnetConfig = supportedNetworks.firstWhere(
        (network) => network.isTestnet,
        orElse: () => NetworkConfig(
          name: 'ICP Testnet',
          rpcUrl: 'https://ic0.testnet.app',
          chainId: '1',
          network: BlockchainNetwork.icp,
          isTestnet: true,
        ),
      );

      final switched = await walletProvider.switchNetwork(testnetConfig);
      expect(switched, isTrue);
    });

    testWidgets('Currency support flow', (WidgetTester tester) async {
      // Initialize
      await nftClient.initialize();

      // Check supported currencies for all providers
      final nftCurrencies = nftProvider.getSupportedCurrencies();
      final walletCurrencies = walletProvider.getSupportedCurrencies();
      final marketplaceCurrencies =
          marketplaceProvider.getSupportedCurrencies();

      expect(nftCurrencies, isA<List<SupportedCurrency>>());
      expect(walletCurrencies, isA<List<SupportedCurrency>>());
      expect(marketplaceCurrencies, isA<List<SupportedCurrency>>());

      // Verify ICP is supported by all
      expect(nftCurrencies.any((c) => c.symbol == 'ICP'), isTrue);
      expect(walletCurrencies.any((c) => c.symbol == 'ICP'), isTrue);
      expect(marketplaceCurrencies.any((c) => c.symbol == 'ICP'), isTrue);

      // Check currency support methods
      expect(walletProvider.isCurrencySupported('ICP'), isTrue);
      expect(walletProvider.isCurrencySupported('BTC'), isFalse);
      expect(marketplaceProvider.isCurrencySupported('ICP'), isTrue);
      expect(marketplaceProvider.isCurrencySupported('ETH'), isFalse);
    });

    testWidgets('Fee estimation flow', (WidgetTester tester) async {
      // Initialize and connect
      await nftClient.initialize();
      await walletProvider.connect();

      // Estimate transaction fees
      final transferFee = await walletProvider.estimateTransactionFee(
        to: 'rdmx6-jaaaa-aaaaa-aaadq-cai',
        amount: 1.0,
        currency: 'ICP',
      );
      expect(transferFee, isA<double>());
      expect(transferFee, greaterThanOrEqualTo(0));

      // Estimate NFT operation fees
      final mintFee = await nftProvider.estimateTransactionFee(
        operation: 'mint',
        params: {'to': 'test-address', 'metadata': {}},
      );
      expect(mintFee, isA<double>());
      expect(mintFee, greaterThan(0));

      // Estimate marketplace fees
      final marketplaceFees = await marketplaceProvider.getMarketplaceFees();
      expect(marketplaceFees, isA<Map<String, double>>());
      expect(marketplaceFees.containsKey('listing'), isTrue);
      expect(marketplaceFees.containsKey('sale'), isTrue);

      final feeCalculation = await marketplaceProvider.calculateFees(
        price: 100.0,
        currency: 'ICP',
      );
      expect(feeCalculation, isA<Map<String, double>>());
      expect(feeCalculation.containsKey('saleFee'), isTrue);
      expect(feeCalculation.containsKey('totalFee'), isTrue);
      expect(feeCalculation.containsKey('netAmount'), isTrue);
    });
  });
}
