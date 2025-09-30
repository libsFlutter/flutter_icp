import 'package:flutter_yuku/flutter_yuku.dart';
import '../core/icp_client.dart';
import '../core/icp_exceptions.dart';
import '../services/yuku_service.dart';

/// ICP implementation of MarketplaceProvider for flutter_yuku
class YukuMarketplaceProvider implements MarketplaceProvider {
  final ICPClient _client = ICPClient.instance;
  final YukuService _yukuService = YukuService();
  bool _isAvailable = false;

  @override
  String get id => 'yuku-marketplace-provider';

  @override
  String get name => 'Yuku Marketplace Provider';

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
      await _yukuService.initialize();
      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      throw ICPServiceNotInitializedException(
        'Failed to initialize Yuku Marketplace provider: $e',
      );
    }
  }

  @override
  Future<void> dispose() async {
    _isAvailable = false;
  }

  @override
  Future<List<NFTListing>> getActiveListings({
    String? contractAddress,
    String? sellerAddress,
    int? limit,
    int? offset,
  }) async {
    _ensureAvailable();

    try {
      final yukuListings = await _yukuService.getActiveListings();
      final listings = <NFTListing>[];

      for (final yukuListing in yukuListings) {
        listings.add(_convertYukuToNFTListing(yukuListing));
      }

      // Apply filters
      if (contractAddress != null) {
        listings.removeWhere(
          (listing) => listing.contractAddress != contractAddress,
        );
      }
      if (sellerAddress != null) {
        listings.removeWhere(
          (listing) => listing.sellerAddress != sellerAddress,
        );
      }

      // Apply limit and offset
      final startIndex = offset ?? 0;
      final endIndex = limit != null ? startIndex + limit : listings.length;

      return listings.sublist(
        startIndex.clamp(0, listings.length),
        endIndex.clamp(0, listings.length),
      );
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get active listings: $e');
    }
  }

  @override
  Future<List<NFTListing>> getUserListings(String userAddress) async {
    _ensureAvailable();

    try {
      final yukuListings = await _yukuService.getMyListings();
      final listings = <NFTListing>[];

      for (final yukuListing in yukuListings) {
        if (yukuListing.sellerAddress == userAddress) {
          listings.add(_convertYukuToNFTListing(yukuListing));
        }
      }

      return listings;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get user listings: $e');
    }
  }

  @override
  Future<NFTListing?> getListing(String listingId) async {
    _ensureAvailable();

    try {
      final yukuListings = await _yukuService.getActiveListings();
      final yukuListing = yukuListings.firstWhere(
        (listing) => listing.id == listingId,
        orElse: () => throw MarketplaceException('Listing not found'),
      );

      return _convertYukuToNFTListing(yukuListing);
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get listing: $e');
    }
  }

  @override
  Future<String> createListing({
    required String nftId,
    required String contractAddress,
    required double price,
    required String currency,
    required String sellerAddress,
    int? expirationDays,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final success = await _yukuService.createListing(
        nftId: nftId,
        price: price,
        currency: currency,
        expirationDays: expirationDays,
      );

      if (!success) {
        throw MarketplaceException('Failed to create listing');
      }

      // Return a mock listing ID - in real implementation, this would come from the service
      return 'listing_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to create listing: $e');
    }
  }

  @override
  Future<bool> cancelListing(String listingId) async {
    _ensureAvailable();

    try {
      return await _yukuService.cancelListing(listingId);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to cancel listing: $e');
    }
  }

  @override
  Future<String> buyNFT({
    required String listingId,
    required String buyerAddress,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final success = await _yukuService.buyNFT(listingId);

      if (!success) {
        throw MarketplaceException('Failed to buy NFT');
      }

      // Return a mock transaction ID
      return 'tx_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to buy NFT: $e');
    }
  }

  @override
  Future<List<NFTOffer>> getActiveOffers({
    String? contractAddress,
    String? nftId,
    String? buyerAddress,
    int? limit,
    int? offset,
  }) async {
    _ensureAvailable();

    try {
      final yukuOffers = await _yukuService.getMyOffers();
      final offers = <NFTOffer>[];

      for (final yukuOffer in yukuOffers) {
        offers.add(_convertYukuToNFTOffer(yukuOffer));
      }

      // Apply filters
      if (contractAddress != null) {
        offers.removeWhere((offer) => offer.contractAddress != contractAddress);
      }
      if (nftId != null) {
        offers.removeWhere((offer) => offer.nftId != nftId);
      }
      if (buyerAddress != null) {
        offers.removeWhere((offer) => offer.buyerAddress != buyerAddress);
      }

      // Apply limit and offset
      final startIndex = offset ?? 0;
      final endIndex = limit != null ? startIndex + limit : offers.length;

      return offers.sublist(
        startIndex.clamp(0, offers.length),
        endIndex.clamp(0, offers.length),
      );
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get active offers: $e');
    }
  }

  @override
  Future<List<NFTOffer>> getUserOffers(String userAddress) async {
    _ensureAvailable();

    try {
      final yukuOffers = await _yukuService.getMyOffers();
      final offers = <NFTOffer>[];

      for (final yukuOffer in yukuOffers) {
        if (yukuOffer.buyerAddress == userAddress) {
          offers.add(_convertYukuToNFTOffer(yukuOffer));
        }
      }

      return offers;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get user offers: $e');
    }
  }

  @override
  Future<List<NFTOffer>> getNFTOffers(
    String nftId,
    String contractAddress,
  ) async {
    _ensureAvailable();

    try {
      final yukuOffers = await _yukuService.getReceivedOffers();
      final offers = <NFTOffer>[];

      for (final yukuOffer in yukuOffers) {
        if (yukuOffer.nftId == nftId) {
          offers.add(_convertYukuToNFTOffer(yukuOffer));
        }
      }

      return offers;
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get NFT offers: $e');
    }
  }

  @override
  Future<NFTOffer?> getOffer(String offerId) async {
    _ensureAvailable();

    try {
      final yukuOffers = await _yukuService.getMyOffers();
      final yukuOffer = yukuOffers.firstWhere(
        (offer) => offer.id == offerId,
        orElse: () => throw MarketplaceException('Offer not found'),
      );

      return _convertYukuToNFTOffer(yukuOffer);
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to get offer: $e');
    }
  }

  @override
  Future<String> makeOffer({
    required String nftId,
    required String contractAddress,
    required double amount,
    required String currency,
    required String buyerAddress,
    int? expirationDays,
    Map<String, dynamic>? additionalParams,
  }) async {
    _ensureAvailable();

    try {
      final success = await _yukuService.makeOffer(
        nftId: nftId,
        amount: amount,
        currency: currency,
        expirationDays: expirationDays,
      );

      if (!success) {
        throw MarketplaceException('Failed to make offer');
      }

      // Return a mock offer ID
      return 'offer_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to make offer: $e');
    }
  }

  @override
  Future<bool> acceptOffer(String offerId) async {
    _ensureAvailable();

    try {
      return await _yukuService.acceptOffer(offerId);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to accept offer: $e');
    }
  }

  @override
  Future<bool> rejectOffer(String offerId) async {
    _ensureAvailable();

    try {
      return await _yukuService.rejectOffer(offerId);
    } catch (e) {
      if (e is ICPServiceNotInitializedException) {
        rethrow;
      }
      throw MarketplaceException('Failed to reject offer: $e');
    }
  }

  @override
  Future<bool> cancelOffer(String offerId) async {
    _ensureAvailable();

    try {
      // Yuku service doesn't have a direct cancel offer method
      // This would need to be implemented based on the actual API
      throw MarketplaceException('Cancel offer not implemented');
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to cancel offer: $e');
    }
  }

  @override
  Future<List<NFTListing>> searchListings({
    String? name,
    String? description,
    Map<String, dynamic>? attributes,
    double? minPrice,
    double? maxPrice,
    String? currency,
    String? contractAddress,
    int? limit,
    int? offset,
  }) async {
    _ensureAvailable();

    try {
      final listings = await getActiveListings(
        contractAddress: contractAddress,
        limit: limit,
        offset: offset,
      );

      // Apply search filters
      final filteredListings = listings.where((listing) {
        if (minPrice != null && listing.price < minPrice) return false;
        if (maxPrice != null && listing.price > maxPrice) return false;
        if (currency != null && listing.currency != currency) return false;

        // Note: name, description, and attributes filtering would require
        // additional NFT metadata queries, which is not implemented in this example

        return true;
      }).toList();

      return filteredListings;
    } catch (e) {
      if (e is ICPServiceNotInitializedException || e is MarketplaceException) {
        rethrow;
      }
      throw MarketplaceException('Failed to search listings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMarketplaceStats() async {
    _ensureAvailable();

    try {
      // This would typically come from the marketplace API
      return {
        'totalListings': await _yukuService.getActiveListings().then(
          (listings) => listings.length,
        ),
        'totalVolume': 0.0, // Would need to be calculated from transactions
        'averagePrice': 0.0, // Would need to be calculated
        'activeUsers': 0, // Would need to be calculated
      };
    } catch (e) {
      throw MarketplaceException('Failed to get marketplace stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCollectionStats(
    String contractAddress,
  ) async {
    _ensureAvailable();

    try {
      final listings = await getActiveListings(
        contractAddress: contractAddress,
      );

      if (listings.isEmpty) {
        return {
          'totalListings': 0,
          'floorPrice': 0.0,
          'averagePrice': 0.0,
          'totalVolume': 0.0,
        };
      }

      final prices = listings.map((listing) => listing.price).toList();
      final floorPrice = prices.reduce((a, b) => a < b ? a : b);
      final averagePrice = prices.reduce((a, b) => a + b) / prices.length;

      return {
        'totalListings': listings.length,
        'floorPrice': floorPrice,
        'averagePrice': averagePrice,
        'totalVolume': 0.0, // Would need to be calculated from historical data
      };
    } catch (e) {
      throw MarketplaceException('Failed to get collection stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserActivity(String userAddress) async {
    _ensureAvailable();

    try {
      final userListings = await getUserListings(userAddress);
      final userOffers = await getUserOffers(userAddress);

      return {
        'listings': {
          'active': userListings
              .where((l) => l.status == ListingStatus.active)
              .length,
          'sold': userListings
              .where((l) => l.status == ListingStatus.sold)
              .length,
          'cancelled': userListings
              .where((l) => l.status == ListingStatus.cancelled)
              .length,
        },
        'offers': {
          'active': userOffers
              .where((o) => o.status == OfferStatus.pending)
              .length,
          'accepted': userOffers
              .where((o) => o.status == OfferStatus.accepted)
              .length,
          'rejected': userOffers
              .where((o) => o.status == OfferStatus.rejected)
              .length,
        },
      };
    } catch (e) {
      throw MarketplaceException('Failed to get user activity: $e');
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
  bool isCurrencySupported(String currency) {
    return getSupportedCurrencies().any((c) => c.symbol == currency);
  }

  @override
  Future<Map<String, double>> getMarketplaceFees() async {
    _ensureAvailable();

    try {
      // Yuku marketplace fees - these would typically come from the API
      return {
        'listing': 0.0, // No listing fee
        'sale': 0.025, // 2.5% sale fee
        'offer': 0.0, // No offer fee
      };
    } catch (e) {
      throw MarketplaceException('Failed to get marketplace fees: $e');
    }
  }

  @override
  Future<Map<String, double>> calculateFees({
    required double price,
    required String currency,
  }) async {
    _ensureAvailable();

    try {
      final fees = await getMarketplaceFees();
      final saleFee = fees['sale'] ?? 0.0;

      return {
        'saleFee': price * saleFee,
        'totalFee': price * saleFee,
        'netAmount': price - (price * saleFee),
      };
    } catch (e) {
      throw MarketplaceException('Failed to calculate fees: $e');
    }
  }

  /// Convert Yuku listing to universal NFT listing
  NFTListing _convertYukuToNFTListing(YukuListing yukuListing) {
    return NFTListing(
      id: yukuListing.id,
      nftId: yukuListing.nftId,
      contractAddress: '', // Would need to be provided
      network: BlockchainNetwork.icp,
      price: yukuListing.price,
      currency: yukuListing.currency,
      sellerAddress: yukuListing.sellerAddress,
      createdAt: yukuListing.createdAt,
      expiresAt: yukuListing.expiresAt,
      status: _convertYukuStatusToNFTStatus(yukuListing.status),
      buyerAddress: yukuListing.buyerAddress,
      soldAt: yukuListing.soldAt,
      marketplaceProvider: id,
    );
  }

  /// Convert Yuku offer to universal NFT offer
  NFTOffer _convertYukuToNFTOffer(YukuOffer yukuOffer) {
    return NFTOffer(
      id: yukuOffer.id,
      nftId: yukuOffer.nftId,
      contractAddress: '', // Would need to be provided
      network: BlockchainNetwork.icp,
      amount: yukuOffer.amount,
      currency: yukuOffer.currency,
      buyerAddress: yukuOffer.buyerAddress,
      createdAt: yukuOffer.createdAt,
      expiresAt: yukuOffer.expiresAt,
      status: _convertYukuOfferStatusToNFTOfferStatus(yukuOffer.status),
      marketplaceProvider: id,
    );
  }

  /// Convert Yuku listing status to NFT listing status
  ListingStatus _convertYukuStatusToNFTStatus(String yukuStatus) {
    switch (yukuStatus.toLowerCase()) {
      case 'active':
        return ListingStatus.active;
      case 'sold':
        return ListingStatus.sold;
      case 'cancelled':
        return ListingStatus.cancelled;
      default:
        return ListingStatus.active;
    }
  }

  /// Convert Yuku offer status to NFT offer status
  OfferStatus _convertYukuOfferStatusToNFTOfferStatus(String yukuStatus) {
    switch (yukuStatus.toLowerCase()) {
      case 'pending':
        return OfferStatus.pending;
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
        return OfferStatus.rejected;
      default:
        return OfferStatus.pending;
    }
  }

  /// Ensure provider is available
  void _ensureAvailable() {
    if (!_isAvailable) {
      throw ICPServiceNotInitializedException(
        'Yuku Marketplace provider is not available',
      );
    }
  }
}
