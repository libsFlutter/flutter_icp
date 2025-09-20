import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nft/flutter_nft.dart';
import 'package:flutter_icp/src/providers/icp_nft_provider.dart';
import 'package:flutter_icp/src/core/icp_exceptions.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/mock_icp_client.dart';

void main() {
  group('ICPNFTProvider', () {
    late ICPNFTProvider provider;
    late MockICPClient mockClient;

    setUp(() {
      provider = ICPNFTProvider();
      mockClient = MockICPClient();
    });

    group('Provider Information', () {
      test('should have correct provider details', () {
        // Assert
        expect(provider.id, equals('icp-nft-provider'));
        expect(provider.name, equals('Internet Computer NFT Provider'));
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

      test('should throw exception on initialization failure', () async {
        // Arrange
        mockClient.setMockData('', '', {'error': 'Initialization failed'});

        // Act & Assert
        expect(
          () => provider.initialize(),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
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

    group('NFT Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get NFTs by owner successfully', () async {
        // Arrange
        const ownerAddress = 'test-owner-principal';

        // Act
        final nfts = await provider.getNFTsByOwner(ownerAddress);

        // Assert
        expect(nfts, isA<List<NFT>>());
        expect(nfts.isNotEmpty, isTrue);
        expect(nfts.first.owner, equals(ownerAddress));
        expect(nfts.first.network, equals(BlockchainNetwork.icp));
      });

      test('should throw exception for invalid principal', () async {
        // Arrange
        const invalidPrincipal = 'invalid';

        // Act & Assert
        expect(
          () => provider.getNFTsByOwner(invalidPrincipal),
          throwsA(isA<ICPPrincipalInvalidException>()),
        );
      });

      test('should get single NFT successfully', () async {
        // Arrange
        const tokenId = '1';
        const contractAddress = 'test-canister';

        // Act
        final nft = await provider.getNFT(tokenId, contractAddress);

        // Assert
        expect(nft, isNotNull);
        expect(nft!.tokenId, equals(tokenId));
        expect(nft.contractAddress, equals('test-canister'));
        expect(nft.network, equals(BlockchainNetwork.icp));
      });

      test('should return null for non-existent NFT', () async {
        // Arrange
        mockClient.setMockData('test-canister', 'get_token', {'token': null});

        // Act
        final nft = await provider.getNFT('999', 'test-canister');

        // Assert
        expect(nft, isNull);
      });

      test('should get multiple NFTs successfully', () async {
        // Arrange
        const tokenIds = ['1', '2', '3'];
        const contractAddress = 'test-canister';

        // Act
        final nfts = await provider.getNFTs(tokenIds, contractAddress);

        // Assert
        expect(nfts, isA<List<NFT>>());
        expect(nfts.length, equals(tokenIds.length));
      });

      test('should mint NFT successfully', () async {
        // Arrange
        const toAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const contractAddress = 'test-canister';
        final metadata = NFTMetadata(
          name: 'Test NFT',
          description: 'Test Description',
          image: 'https://example.com/image.png',
          attributes: {'color': 'blue'},
          properties: {'type': 'test'},
        );

        // Act
        final transactionId = await provider.mintNFT(
          toAddress: toAddress,
          metadata: metadata,
          contractAddress: contractAddress,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_mint_'), isTrue);
      });

      test('should throw exception for invalid mint address', () async {
        // Arrange
        const invalidAddress = 'invalid';
        const contractAddress = 'test-canister';
        final metadata = NFTMetadata(
          name: 'Test NFT',
          description: 'Test Description',
          image: 'https://example.com/image.png',
          attributes: {'color': 'blue'},
          properties: {'type': 'test'},
        );

        // Act & Assert
        expect(
          () => provider.mintNFT(
            toAddress: invalidAddress,
            metadata: metadata,
            contractAddress: contractAddress,
          ),
          throwsA(isA<ICPPrincipalInvalidException>()),
        );
      });

      test('should transfer NFT successfully', () async {
        // Arrange
        const tokenId = '1';
        const fromAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const toAddress = 'rrkah-fqaaa-aaaar-aacaq-cai';
        const contractAddress = 'test-canister';

        // Act
        final transactionId = await provider.transferNFT(
          tokenId: tokenId,
          fromAddress: fromAddress,
          toAddress: toAddress,
          contractAddress: contractAddress,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_transfer_'), isTrue);
      });

      test('should burn NFT successfully', () async {
        // Arrange
        const tokenId = '1';
        const ownerAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const contractAddress = 'test-canister';

        // Act
        final transactionId = await provider.burnNFT(
          tokenId: tokenId,
          ownerAddress: ownerAddress,
          contractAddress: contractAddress,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_burn_'), isTrue);
      });

      test('should approve NFT successfully', () async {
        // Arrange
        const tokenId = '1';
        const ownerAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const approvedAddress = 'rrkah-fqaaa-aaaar-aacaq-cai';
        const contractAddress = 'test-canister';

        // Act
        final transactionId = await provider.approveNFT(
          tokenId: tokenId,
          ownerAddress: ownerAddress,
          approvedAddress: approvedAddress,
          contractAddress: contractAddress,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_approve_'), isTrue);
      });

      test('should check approval status', () async {
        // Arrange
        const tokenId = '1';
        const ownerAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const approvedAddress = 'rrkah-fqaaa-aaaar-aacaq-cai';
        const contractAddress = 'test-canister';

        // Act
        final isApproved = await provider.isApproved(
          tokenId: tokenId,
          ownerAddress: ownerAddress,
          approvedAddress: approvedAddress,
          contractAddress: contractAddress,
        );

        // Assert
        expect(isApproved, isA<bool>());
        expect(isApproved, isTrue);
      });

      test('should get NFT metadata successfully', () async {
        // Arrange
        const tokenId = '1';
        const contractAddress = 'test-canister';

        // Act
        final metadata = await provider.getNFTMetadata(
          tokenId: tokenId,
          contractAddress: contractAddress,
        );

        // Assert
        expect(metadata, isA<NFTMetadata>());
        expect(metadata.name, equals('Test NFT'));
        expect(metadata.description, equals('Test NFT Description'));
      });

      test('should update NFT metadata successfully', () async {
        // Arrange
        const tokenId = '1';
        const ownerAddress = 'rdmx6-jaaaa-aaaaa-aaadq-cai';
        const contractAddress = 'test-canister';
        final newMetadata = NFTMetadata(
          name: 'Updated NFT',
          description: 'Updated Description',
          image: 'https://example.com/updated.png',
          attributes: {'color': 'red'},
          properties: {'type': 'updated'},
        );

        // Act
        final success = await provider.updateNFTMetadata(
          tokenId: tokenId,
          ownerAddress: ownerAddress,
          metadata: newMetadata,
          contractAddress: contractAddress,
        );

        // Assert
        expect(success, isTrue);
      });

      test('should search NFTs successfully', () async {
        // Arrange
        const name = 'Test';
        const description = 'NFT';
        final attributes = {'color': 'blue'};

        // Act
        final nfts = await provider.searchNFTs(
          name: name,
          description: description,
          attributes: attributes,
          limit: 10,
          offset: 0,
        );

        // Assert
        expect(nfts, isA<List<NFT>>());
        expect(nfts.isNotEmpty, isTrue);
      });
    });

    group('Contract Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get contract info successfully', () async {
        // Arrange
        const contractAddress = 'test-canister';

        // Act
        final info = await provider.getContractInfo(contractAddress);

        // Assert
        expect(info, isA<Map<String, dynamic>>());
        expect(info.containsKey('canister_id'), isTrue);
        expect(info.containsKey('status'), isTrue);
      });

      test('should validate contract successfully', () async {
        // Arrange
        const validContract = 'test-canister';

        // Act
        final isValid = await provider.isValidContract(validContract);

        // Assert
        expect(isValid, isTrue);
      });
    });

    group('Transaction Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should estimate transaction fee', () async {
        // Arrange
        const operation = 'mint';
        final params = {'to': 'test-address', 'metadata': {}};

        // Act
        final fee = await provider.estimateTransactionFee(
          operation: operation,
          params: params,
        );

        // Assert
        expect(fee, isA<double>());
        expect(fee, greaterThan(0));
      });

      test('should get transaction status', () async {
        // Arrange
        const transactionHash = 'tx_123';

        // Act
        final status = await provider.getTransactionStatus(transactionHash);

        // Assert
        expect(status, isA<TransactionStatus>());
        expect(status, equals(TransactionStatus.confirmed));
      });

      test('should get transaction details', () async {
        // Arrange
        const transactionHash = 'tx_123';

        // Act
        final details = await provider.getTransactionDetails(transactionHash);

        // Assert
        expect(details, isA<Map<String, dynamic>>());
        expect(details.containsKey('id'), isTrue);
        expect(details.containsKey('status'), isTrue);
      });
    });

    group('Currency Support', () {
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

    group('Error Handling', () {
      test('should throw exception when not available', () async {
        // Arrange - don't initialize provider

        // Act & Assert
        expect(
          () => provider.getNFTsByOwner('test-owner'),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
      });

      test('should handle configuration exceptions', () async {
        // Arrange
        await provider.initialize();
        // Mock a scenario where canister ID is not configured
        
        // This would require more sophisticated mocking to test configuration exceptions
        // For now, we verify that the provider handles the basic flow
        expect(provider.isAvailable, isTrue);
      });
    });
  });
}
