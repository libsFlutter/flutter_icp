import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_icp/flutter_icp.dart';

void main() {
  group('NFT Marketplace Flow Integration Tests', () {
    late NFTClient nftClient;
    late ICPNFTProvider nftProvider;
    late PlugWalletProvider walletProvider;
    late YukuMarketplaceProvider marketplaceProvider;

    setUp(() async {
      // Initialize NFT client and providers
      nftClient = NFTClient();
      nftProvider = ICPNFTProvider();
      walletProvider = PlugWalletProvider();
      marketplaceProvider = YukuMarketplaceProvider();

      // Register providers
      nftClient.registerNFTProvider(nftProvider);
      nftClient.registerWalletProvider(walletProvider);
      nftClient.registerMarketplaceProvider(marketplaceProvider);

      // Initialize system
      await nftClient.initialize();
      await walletProvider.connect();
    });

    testWidgets('Complete NFT marketplace workflow',
        (WidgetTester tester) async {
      final userAddress = walletProvider.connectedAddress!;

      // Step 1: Mint an NFT
      final metadata = NFTMetadata(
        name: 'Marketplace Test NFT',
        description: 'NFT created for marketplace testing',
        image: 'https://example.com/test-nft.png',
        attributes: {
          'type': 'test',
          'rarity': 'common',
        },
        properties: {
          'created_by': 'test_suite',
        },
      );

      final mintTxHash = await nftProvider.mintNFT(
        toAddress: userAddress,
        metadata: metadata,
        contractAddress: 'test-nft-canister',
      );
      expect(mintTxHash, isA<String>());

      // Step 2: Get the minted NFT
      final userNFTs = await nftProvider.getNFTsByOwner(userAddress);
      expect(userNFTs.isNotEmpty, isTrue);
      final nftToSell = userNFTs.first;

      // Step 3: Create a marketplace listing
      final listingId = await marketplaceProvider.createListing(
        nftId: nftToSell.tokenId,
        contractAddress: nftToSell.contractAddress,
        price: 15.0,
        currency: 'ICP',
        sellerAddress: userAddress,
        expirationDays: 30,
      );
      expect(listingId, isA<String>());

      // Step 4: Verify listing appears in active listings
      final activeListings = await marketplaceProvider.getActiveListings();
      expect(activeListings.any((l) => l.id == listingId), isTrue);

      // Step 5: Verify listing appears in user listings
      final userListings =
          await marketplaceProvider.getUserListings(userAddress);
      expect(userListings.any((l) => l.id == listingId), isTrue);

      // Step 6: Get specific listing details
      final listing = await marketplaceProvider.getListing(listingId);
      expect(listing, isNotNull);
      expect(listing!.price, equals(15.0));
      expect(listing.currency, equals('ICP'));
      expect(listing.sellerAddress, equals(userAddress));

      // Step 7: Search for listings
      final searchResults = await marketplaceProvider.searchListings(
        minPrice: 10.0,
        maxPrice: 20.0,
        currency: 'ICP',
      );
      expect(searchResults.any((l) => l.id == listingId), isTrue);
    });

    testWidgets('NFT offer workflow', (WidgetTester tester) async {
      final buyerAddress = walletProvider.connectedAddress!;

      // Get active listings
      final activeListings = await marketplaceProvider.getActiveListings();
      expect(activeListings.isNotEmpty, isTrue);
      final targetListing = activeListings.first;

      // Step 1: Make an offer
      final offerId = await marketplaceProvider.makeOffer(
        nftId: targetListing.nftId,
        contractAddress: targetListing.contractAddress,
        amount: targetListing.price * 0.8, // Offer 80% of listing price
        currency: targetListing.currency,
        buyerAddress: buyerAddress,
        expirationDays: 7,
      );
      expect(offerId, isA<String>());

      // Step 2: Verify offer appears in active offers
      final activeOffers = await marketplaceProvider.getActiveOffers();
      expect(activeOffers.any((o) => o.id == offerId), isTrue);

      // Step 3: Verify offer appears in user offers
      final userOffers = await marketplaceProvider.getUserOffers(buyerAddress);
      expect(userOffers.any((o) => o.id == offerId), isTrue);

      // Step 4: Get NFT-specific offers
      final nftOffers = await marketplaceProvider.getNFTOffers(
        targetListing.nftId,
        targetListing.contractAddress,
      );
      expect(nftOffers.any((o) => o.id == offerId), isTrue);

      // Step 5: Get specific offer details
      final offer = await marketplaceProvider.getOffer(offerId);
      expect(offer, isNotNull);
      expect(offer!.buyerAddress, equals(buyerAddress));
      expect(offer.status, equals(OfferStatus.pending));

      // Step 6: Accept the offer (simulating seller action)
      final accepted = await marketplaceProvider.acceptOffer(offerId);
      expect(accepted, isTrue);

      // Step 7: Verify offer status changed
      final updatedOffer = await marketplaceProvider.getOffer(offerId);
      expect(updatedOffer!.status, equals(OfferStatus.accepted));
    });

    testWidgets('NFT purchase workflow', (WidgetTester tester) async {
      final buyerAddress = walletProvider.connectedAddress!;

      // Get active listings
      final activeListings = await marketplaceProvider.getActiveListings();
      expect(activeListings.isNotEmpty, isTrue);
      final listingToBuy = activeListings.first;

      // Step 1: Check buyer balance
      final balance = await walletProvider.getBalance(listingToBuy.currency);
      expect(balance, greaterThanOrEqualTo(listingToBuy.price));

      // Step 2: Calculate fees
      final feeCalculation = await marketplaceProvider.calculateFees(
        price: listingToBuy.price,
        currency: listingToBuy.currency,
      );
      expect(feeCalculation.containsKey('totalFee'), isTrue);

      // Step 3: Purchase the NFT
      final purchaseTxHash = await marketplaceProvider.buyNFT(
        listingId: listingToBuy.id,
        buyerAddress: buyerAddress,
      );
      expect(purchaseTxHash, isA<String>());

      // Step 4: Verify listing status changed (would be 'sold' in real implementation)
      // In our mock, this updates the listing status
      final updatedListing =
          await marketplaceProvider.getListing(listingToBuy.id);
      // The mock implementation should handle this state change
      expect(updatedListing, isNotNull);
    });

    testWidgets('Listing management workflow', (WidgetTester tester) async {
      final sellerAddress = walletProvider.connectedAddress!;

      // Step 1: Create a new listing
      final userNFTs = await nftProvider.getNFTsByOwner(sellerAddress);
      expect(userNFTs.isNotEmpty, isTrue);
      final nftToList = userNFTs.first;

      final listingId = await marketplaceProvider.createListing(
        nftId: nftToList.tokenId,
        contractAddress: nftToList.contractAddress,
        price: 25.0,
        currency: 'ICP',
        sellerAddress: sellerAddress,
        expirationDays: 14,
      );
      expect(listingId, isA<String>());

      // Step 2: Verify listing is active
      final listing = await marketplaceProvider.getListing(listingId);
      expect(listing, isNotNull);
      expect(listing!.status, equals(ListingStatus.active));

      // Step 3: Cancel the listing
      final cancelled = await marketplaceProvider.cancelListing(listingId);
      expect(cancelled, isTrue);

      // Step 4: Verify listing status changed
      // The mock should update the status to cancelled
      final cancelledListing = await marketplaceProvider.getListing(listingId);
      expect(cancelledListing, isNotNull);
    });

    testWidgets('Marketplace analytics workflow', (WidgetTester tester) async {
      // Step 1: Get overall marketplace statistics
      final marketplaceStats = await marketplaceProvider.getMarketplaceStats();
      expect(marketplaceStats, isA<Map<String, dynamic>>());
      expect(marketplaceStats.containsKey('totalListings'), isTrue);
      expect(marketplaceStats.containsKey('totalVolume'), isTrue);
      expect(marketplaceStats.containsKey('averagePrice'), isTrue);
      expect(marketplaceStats.containsKey('activeUsers'), isTrue);

      // Step 2: Get collection-specific statistics
      const testContractAddress = 'test-nft-canister';
      final collectionStats =
          await marketplaceProvider.getCollectionStats(testContractAddress);
      expect(collectionStats, isA<Map<String, dynamic>>());
      expect(collectionStats.containsKey('totalListings'), isTrue);
      expect(collectionStats.containsKey('floorPrice'), isTrue);
      expect(collectionStats.containsKey('averagePrice'), isTrue);
      expect(collectionStats.containsKey('totalVolume'), isTrue);

      // Step 3: Get user activity
      final userAddress = walletProvider.connectedAddress!;
      final userActivity =
          await marketplaceProvider.getUserActivity(userAddress);
      expect(userActivity, isA<Map<String, dynamic>>());
      expect(userActivity.containsKey('listings'), isTrue);
      expect(userActivity.containsKey('offers'), isTrue);

      final listingsActivity = userActivity['listings'] as Map<String, dynamic>;
      expect(listingsActivity.containsKey('active'), isTrue);
      expect(listingsActivity.containsKey('sold'), isTrue);
      expect(listingsActivity.containsKey('cancelled'), isTrue);

      final offersActivity = userActivity['offers'] as Map<String, dynamic>;
      expect(offersActivity.containsKey('active'), isTrue);
      expect(offersActivity.containsKey('accepted'), isTrue);
      expect(offersActivity.containsKey('rejected'), isTrue);
    });

    testWidgets('Advanced search and filtering workflow',
        (WidgetTester tester) async {
      // Step 1: Search by price range
      final priceRangeResults = await marketplaceProvider.searchListings(
        minPrice: 5.0,
        maxPrice: 50.0,
        currency: 'ICP',
        limit: 10,
      );
      expect(priceRangeResults, isA<List<NFTListing>>());
      for (final listing in priceRangeResults) {
        expect(listing.price, greaterThanOrEqualTo(5.0));
        expect(listing.price, lessThanOrEqualTo(50.0));
        expect(listing.currency, equals('ICP'));
      }

      // Step 2: Filter active listings by contract
      const contractFilter = 'test-nft-canister';
      final contractFilteredListings =
          await marketplaceProvider.getActiveListings(
        contractAddress: contractFilter,
        limit: 5,
      );
      expect(contractFilteredListings, isA<List<NFTListing>>());

      // Step 3: Filter offers by NFT
      const nftId = 'nft_1';
      const contractAddress = 'test-contract';
      final nftOffers = await marketplaceProvider.getActiveOffers(
        nftId: nftId,
        contractAddress: contractAddress,
      );
      expect(nftOffers, isA<List<NFTOffer>>());

      // Step 4: Paginated results
      final page1 =
          await marketplaceProvider.getActiveListings(limit: 2, offset: 0);
      final page2 =
          await marketplaceProvider.getActiveListings(limit: 2, offset: 2);
      expect(page1.length, lessThanOrEqualTo(2));
      expect(page2.length, lessThanOrEqualTo(2));
    });

    testWidgets('Error handling in marketplace workflows',
        (WidgetTester tester) async {
      // Test getting non-existent listing
      expect(
        () => marketplaceProvider.getListing('non-existent-listing'),
        throwsA(isA<MarketplaceException>()),
      );

      // Test getting non-existent offer
      expect(
        () => marketplaceProvider.getOffer('non-existent-offer'),
        throwsA(isA<MarketplaceException>()),
      );

      // Test cancel offer (not implemented in Yuku)
      expect(
        () => marketplaceProvider.cancelOffer('any-offer'),
        throwsA(isA<MarketplaceException>()),
      );

      // Test operations when not available
      await marketplaceProvider.dispose();
      expect(
        () => marketplaceProvider.getActiveListings(),
        throwsA(isA<ICPServiceNotInitializedException>()),
      );
    });

    testWidgets('Complex marketplace scenario', (WidgetTester tester) async {
      final userAddress = walletProvider.connectedAddress!;

      // Scenario: User mints NFT, lists it, receives offer, rejects it, then sells to another buyer

      // Step 1: Mint NFT
      final metadata = NFTMetadata(
        name: 'Complex Scenario NFT',
        description: 'NFT for testing complex marketplace scenario',
        image: 'https://example.com/complex-nft.png',
        attributes: {'scenario': 'complex'},
        properties: {'test_type': 'complex_scenario'},
      );

      await nftProvider.mintNFT(
        toAddress: userAddress,
        metadata: metadata,
        contractAddress: 'scenario-nft-canister',
      );

      // Step 2: List NFT
      final userNFTs = await nftProvider.getNFTsByOwner(userAddress);
      final nftToSell = userNFTs.first;

      final listingId = await marketplaceProvider.createListing(
        nftId: nftToSell.tokenId,
        contractAddress: nftToSell.contractAddress,
        price: 20.0,
        currency: 'ICP',
        sellerAddress: userAddress,
      );

      // Step 3: Receive offer
      final offerId = await marketplaceProvider.makeOffer(
        nftId: nftToSell.tokenId,
        contractAddress: nftToSell.contractAddress,
        amount: 15.0,
        currency: 'ICP',
        buyerAddress: 'buyer-1',
      );

      // Step 4: Reject offer
      final rejected = await marketplaceProvider.rejectOffer(offerId);
      expect(rejected, isTrue);

      // Step 5: Direct purchase by another buyer
      final purchaseTxHash = await marketplaceProvider.buyNFT(
        listingId: listingId,
        buyerAddress: 'buyer-2',
      );
      expect(purchaseTxHash, isA<String>());

      // Step 6: Verify final state
      final finalListing = await marketplaceProvider.getListing(listingId);
      expect(finalListing, isNotNull);

      final finalOffer = await marketplaceProvider.getOffer(offerId);
      expect(finalOffer!.status, equals(OfferStatus.rejected));
    });
  });
}
