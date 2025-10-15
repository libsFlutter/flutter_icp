import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_icp/src/providers/yuku_marketplace_provider.dart';
import 'package:flutter_icp/src/core/icp_exceptions.dart';
import '../../mocks/mock_services.dart';

void main() {
  group('YukuMarketplaceProvider', () {
    late YukuMarketplaceProvider provider;
    late MockYukuService mockYukuService;

    setUp(() {
      provider = YukuMarketplaceProvider();
      mockYukuService = MockYukuService();
    });

    group('Provider Information', () {
      test('should have correct provider details', () {
        // Assert
        expect(provider.id, equals('yuku-marketplace-provider'));
        expect(provider.name, equals('Yuku Marketplace Provider'));
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

    group('Listing Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get active listings successfully', () async {
        // Act
        final listings = await provider.getActiveListings();

        // Assert
        expect(listings, isA<List<NFTListing>>());
        expect(listings.isNotEmpty, isTrue);
        expect(listings.first.network, equals(BlockchainNetwork.icp));
        expect(listings.first.marketplaceProvider, equals(provider.id));
      });

      test('should get active listings with filters', () async {
        // Arrange
        const contractAddress = 'test-contract';
        const sellerAddress = 'test-seller';
        const limit = 5;
        const offset = 0;

        // Act
        final listings = await provider.getActiveListings(
          contractAddress: contractAddress,
          sellerAddress: sellerAddress,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(listings, isA<List<NFTListing>>());
        expect(listings.length, lessThanOrEqualTo(limit));
      });

      test('should get user listings successfully', () async {
        // Arrange
        const userAddress = 'test-user';

        // Act
        final listings = await provider.getUserListings(userAddress);

        // Assert
        expect(listings, isA<List<NFTListing>>());
      });

      test('should get specific listing successfully', () async {
        // Arrange
        const listingId = 'listing_1';

        // Act
        final listing = await provider.getListing(listingId);

        // Assert
        expect(listing, isNotNull);
        expect(listing!.id, equals(listingId));
        expect(listing.network, equals(BlockchainNetwork.icp));
      });

      test('should throw exception for non-existent listing', () async {
        // Arrange
        const nonExistentId = 'non-existent';

        // Act & Assert
        expect(
          () => provider.getListing(nonExistentId),
          throwsA(isA<MarketplaceException>()),
        );
      });

      test('should create listing successfully', () async {
        // Arrange
        const nftId = 'nft_1';
        const contractAddress = 'test-contract';
        const price = 10.0;
        const currency = 'ICP';
        const sellerAddress = 'test-seller';
        const expirationDays = 7;

        // Act
        final listingId = await provider.createListing(
          nftId: nftId,
          contractAddress: contractAddress,
          price: price,
          currency: currency,
          sellerAddress: sellerAddress,
          expirationDays: expirationDays,
        );

        // Assert
        expect(listingId, isA<String>());
        expect(listingId.startsWith('listing_'), isTrue);
      });

      test('should cancel listing successfully', () async {
        // Arrange
        const listingId = 'listing_1';

        // Act
        final success = await provider.cancelListing(listingId);

        // Assert
        expect(success, isTrue);
      });

      test('should buy NFT successfully', () async {
        // Arrange
        const listingId = 'listing_1';
        const buyerAddress = 'test-buyer';

        // Act
        final transactionId = await provider.buyNFT(
          listingId: listingId,
          buyerAddress: buyerAddress,
        );

        // Assert
        expect(transactionId, isA<String>());
        expect(transactionId.startsWith('tx_'), isTrue);
      });

      test('should search listings successfully', () async {
        // Arrange
        const name = 'Test';
        const minPrice = 5.0;
        const maxPrice = 15.0;
        const currency = 'ICP';

        // Act
        final listings = await provider.searchListings(
          name: name,
          minPrice: minPrice,
          maxPrice: maxPrice,
          currency: currency,
          limit: 10,
        );

        // Assert
        expect(listings, isA<List<NFTListing>>());
        for (final listing in listings) {
          expect(listing.price, greaterThanOrEqualTo(minPrice));
          expect(listing.price, lessThanOrEqualTo(maxPrice));
          expect(listing.currency, equals(currency));
        }
      });
    });

    group('Offer Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get active offers successfully', () async {
        // Act
        final offers = await provider.getActiveOffers();

        // Assert
        expect(offers, isA<List<NFTOffer>>());
      });

      test('should get active offers with filters', () async {
        // Arrange
        const contractAddress = 'test-contract';
        const nftId = 'nft_1';
        const buyerAddress = 'test-buyer';

        // Act
        final offers = await provider.getActiveOffers(
          contractAddress: contractAddress,
          nftId: nftId,
          buyerAddress: buyerAddress,
          limit: 5,
        );

        // Assert
        expect(offers, isA<List<NFTOffer>>());
      });

      test('should get user offers successfully', () async {
        // Arrange
        const userAddress = 'test-user';

        // Act
        final offers = await provider.getUserOffers(userAddress);

        // Assert
        expect(offers, isA<List<NFTOffer>>());
      });

      test('should get NFT offers successfully', () async {
        // Arrange
        const nftId = 'nft_1';
        const contractAddress = 'test-contract';

        // Act
        final offers = await provider.getNFTOffers(nftId, contractAddress);

        // Assert
        expect(offers, isA<List<NFTOffer>>());
      });

      test('should get specific offer successfully', () async {
        // Arrange
        const offerId = 'offer_1';

        // Act
        final offer = await provider.getOffer(offerId);

        // Assert
        expect(offer, isNotNull);
        expect(offer!.id, equals(offerId));
        expect(offer.network, equals(BlockchainNetwork.icp));
      });

      test('should make offer successfully', () async {
        // Arrange
        const nftId = 'nft_1';
        const contractAddress = 'test-contract';
        const amount = 8.0;
        const currency = 'ICP';
        const buyerAddress = 'test-buyer';
        const expirationDays = 3;

        // Act
        final offerId = await provider.makeOffer(
          nftId: nftId,
          contractAddress: contractAddress,
          amount: amount,
          currency: currency,
          buyerAddress: buyerAddress,
          expirationDays: expirationDays,
        );

        // Assert
        expect(offerId, isA<String>());
        expect(offerId.startsWith('offer_'), isTrue);
      });

      test('should accept offer successfully', () async {
        // Arrange
        const offerId = 'offer_1';

        // Act
        final success = await provider.acceptOffer(offerId);

        // Assert
        expect(success, isTrue);
      });

      test('should reject offer successfully', () async {
        // Arrange
        const offerId = 'offer_1';

        // Act
        final success = await provider.rejectOffer(offerId);

        // Assert
        expect(success, isTrue);
      });

      test('should throw exception for cancel offer (not implemented)', () async {
        // Arrange
        const offerId = 'offer_1';

        // Act & Assert
        expect(
          () => provider.cancelOffer(offerId),
          throwsA(isA<MarketplaceException>()),
        );
      });
    });

    group('Statistics and Analytics', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get marketplace stats successfully', () async {
        // Act
        final stats = await provider.getMarketplaceStats();

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('totalListings'), isTrue);
        expect(stats.containsKey('totalVolume'), isTrue);
        expect(stats.containsKey('averagePrice'), isTrue);
        expect(stats.containsKey('activeUsers'), isTrue);
      });

      test('should get collection stats successfully', () async {
        // Arrange
        const contractAddress = 'test-contract';

        // Act
        final stats = await provider.getCollectionStats(contractAddress);

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('totalListings'), isTrue);
        expect(stats.containsKey('floorPrice'), isTrue);
        expect(stats.containsKey('averagePrice'), isTrue);
        expect(stats.containsKey('totalVolume'), isTrue);
      });

      test('should get user activity successfully', () async {
        // Arrange
        const userAddress = 'test-user';

        // Act
        final activity = await provider.getUserActivity(userAddress);

        // Assert
        expect(activity, isA<Map<String, dynamic>>());
        expect(activity.containsKey('listings'), isTrue);
        expect(activity.containsKey('offers'), isTrue);
        expect(activity['listings'], isA<Map<String, dynamic>>());
        expect(activity['offers'], isA<Map<String, dynamic>>());
      });
    });

    group('Fee Operations', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should get marketplace fees successfully', () async {
        // Act
        final fees = await provider.getMarketplaceFees();

        // Assert
        expect(fees, isA<Map<String, double>>());
        expect(fees.containsKey('listing'), isTrue);
        expect(fees.containsKey('sale'), isTrue);
        expect(fees.containsKey('offer'), isTrue);
      });

      test('should calculate fees successfully', () async {
        // Arrange
        const price = 100.0;
        const currency = 'ICP';

        // Act
        final feeCalculation = await provider.calculateFees(
          price: price,
          currency: currency,
        );

        // Assert
        expect(feeCalculation, isA<Map<String, double>>());
        expect(feeCalculation.containsKey('saleFee'), isTrue);
        expect(feeCalculation.containsKey('totalFee'), isTrue);
        expect(feeCalculation.containsKey('netAmount'), isTrue);
        expect(feeCalculation['netAmount']! + feeCalculation['totalFee']!, equals(price));
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

    group('Error Handling', () {
      test('should throw exception when not available', () async {
        // Arrange - don't initialize provider

        // Act & Assert
        expect(
          () => provider.getActiveListings(),
          throwsA(isA<ICPServiceNotInitializedException>()),
        );
      });

      test('should handle marketplace service failures', () async {
        // Arrange
        await provider.initialize();
        mockYukuService.clearAll(); // Clear mock data to simulate empty results

        // Act
        final listings = await provider.getActiveListings();

        // Assert
        expect(listings, isEmpty);
      });

      test('should handle collection stats for empty collections', () async {
        // Arrange
        await provider.initialize();
        const emptyContractAddress = 'empty-contract';

        // Act
        final stats = await provider.getCollectionStats(emptyContractAddress);

        // Assert
        expect(stats['totalListings'], equals(0));
        expect(stats['floorPrice'], equals(0.0));
        expect(stats['averagePrice'], equals(0.0));
        expect(stats['totalVolume'], equals(0.0));
      });
    });

    group('Data Conversion', () {
      setUp(() async {
        await provider.initialize();
      });

      test('should convert Yuku listings to NFT listings correctly', () async {
        // Act
        final listings = await provider.getActiveListings();

        // Assert
        for (final listing in listings) {
          expect(listing.network, equals(BlockchainNetwork.icp));
          expect(listing.marketplaceProvider, equals(provider.id));
          expect(listing.id, isNotNull);
          expect(listing.nftId, isNotNull);
          expect(listing.price, greaterThan(0));
          expect(listing.currency, isNotNull);
          expect(listing.sellerAddress, isNotNull);
          expect(listing.createdAt, isNotNull);
        }
      });

      test('should convert Yuku offers to NFT offers correctly', () async {
        // Act
        final offers = await provider.getActiveOffers();

        // Assert
        for (final offer in offers) {
          expect(offer.network, equals(BlockchainNetwork.icp));
          expect(offer.marketplaceProvider, equals(provider.id));
          expect(offer.id, isNotNull);
          expect(offer.nftId, isNotNull);
          expect(offer.amount, greaterThan(0));
          expect(offer.currency, isNotNull);
          expect(offer.buyerAddress, isNotNull);
          expect(offer.createdAt, isNotNull);
        }
      });
    });
  });
}
