import 'package:flutter_icp/src/services/plug_wallet_service.dart';
import 'package:flutter_icp/src/services/yuku_service.dart';
import 'package:mockito/mockito.dart';

/// Mock implementation of PlugWalletService for testing
class MockPlugWalletService extends Mock implements PlugWalletService {
  bool _isConnected = false;
  String? _principalId;
  String? _accountId;
  final Map<String, double> _balances = {'ICP': 10.5, 'WICP': 5.2};
  final List<Map<String, dynamic>> _transactionHistory = [];

  @override
  bool get isConnected => _isConnected;

  @override
  String? get principalId => _principalId;

  @override
  String? get accountId => _accountId;

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<bool> connect() async {
    _isConnected = true;
    _principalId = 'test-principal-id';
    _accountId = 'test-account-id';
    return true;
  }

  @override
  Future<bool> disconnect() async {
    _isConnected = false;
    _principalId = null;
    _accountId = null;
    return true;
  }

  @override
  Future<Map<String, double>> getBalance() async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return Map.from(_balances);
  }

  @override
  Future<bool> sendTransaction({
    required String to,
    required double amount,
    required String currency,
    String? memo,
  }) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    
    // Mock transaction
    _transactionHistory.add({
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'to': to,
      'amount': amount,
      'currency': currency,
      'memo': memo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    return true;
  }

  @override
  Future<bool> signMessage(String message) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return true;
  }

  @override
  Future<bool> approveTransaction({
    required String canisterId,
    required String method,
    required Map<String, dynamic> args,
  }) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return List.from(_transactionHistory);
  }

  @override
  Future<Map<String, dynamic>> getTransactionDetails(String transactionHash) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    
    final tx = _transactionHistory.firstWhere(
      (tx) => tx['id'] == transactionHash,
      orElse: () => {
        'id': transactionHash,
        'status': 'confirmed',
        'amount': 1.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    return Map.from(tx);
  }

  @override
  Future<Map<String, dynamic>> getWalletStats() async {
    if (!_isConnected) throw Exception('Wallet not connected');
    
    return {
      'totalTransactions': _transactionHistory.length,
      'totalBalance': _balances.values.fold(0.0, (sum, balance) => sum + balance),
      'connectedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  Future<bool> approveNFTTransaction({
    required String nftCanisterId,
    required String nftId,
    required double price,
    required String currency,
  }) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return true;
  }

  @override
  Future<bool> approveListingTransaction({
    required String marketplaceCanisterId,
    required String nftId,
    required double price,
    required String currency,
  }) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return true;
  }

  @override
  Future<bool> approveOfferTransaction({
    required String marketplaceCanisterId,
    required String nftId,
    required double amount,
    required String currency,
  }) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    return true;
  }

  // Test helpers
  void setBalance(String currency, double balance) {
    _balances[currency] = balance;
  }

  void addTransaction(Map<String, dynamic> transaction) {
    _transactionHistory.add(transaction);
  }
}

/// Mock implementation of YukuService for testing
class MockYukuService extends Mock implements YukuService {
  final List<YukuListing> _activeListings = [];
  final List<YukuListing> _myListings = [];
  final List<YukuOffer> _myOffers = [];
  final List<YukuOffer> _receivedOffers = [];

  @override
  Future<void> initialize() async {
    // Mock initialization
    _setupMockData();
  }

  @override
  Future<List<YukuListing>> getActiveListings() async {
    return List.from(_activeListings);
  }

  @override
  Future<List<YukuListing>> getMyListings() async {
    return List.from(_myListings);
  }

  @override
  Future<List<YukuOffer>> getMyOffers() async {
    return List.from(_myOffers);
  }

  @override
  Future<List<YukuOffer>> getReceivedOffers() async {
    return List.from(_receivedOffers);
  }

  @override
  Future<bool> createListing({
    required String nftId,
    required double price,
    required String currency,
    int? expirationDays,
  }) async {
    final listing = YukuListing(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
      nftId: nftId,
      price: price,
      currency: currency,
      sellerAddress: 'test-seller',
      createdAt: DateTime.now(),
      expiresAt: expirationDays != null 
          ? DateTime.now().add(Duration(days: expirationDays))
          : null,
      status: 'active',
    );
    
    _activeListings.add(listing);
    _myListings.add(listing);
    return true;
  }

  @override
  Future<bool> cancelListing(String listingId) async {
    final index = _activeListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final listing = _activeListings[index];
      _activeListings[index] = YukuListing(
        id: listing.id,
        nftId: listing.nftId,
        price: listing.price,
        currency: listing.currency,
        sellerAddress: listing.sellerAddress,
        createdAt: listing.createdAt,
        expiresAt: listing.expiresAt,
        status: 'cancelled',
        buyerAddress: listing.buyerAddress,
        soldAt: listing.soldAt,
      );
    }
    
    final myIndex = _myListings.indexWhere((l) => l.id == listingId);
    if (myIndex != -1) {
      final listing = _myListings[myIndex];
      _myListings[myIndex] = YukuListing(
        id: listing.id,
        nftId: listing.nftId,
        price: listing.price,
        currency: listing.currency,
        sellerAddress: listing.sellerAddress,
        createdAt: listing.createdAt,
        expiresAt: listing.expiresAt,
        status: 'cancelled',
        buyerAddress: listing.buyerAddress,
        soldAt: listing.soldAt,
      );
    }
    
    return index != -1;
  }

  @override
  Future<bool> buyNFT(String listingId) async {
    final index = _activeListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final listing = _activeListings[index];
      _activeListings[index] = YukuListing(
        id: listing.id,
        nftId: listing.nftId,
        price: listing.price,
        currency: listing.currency,
        sellerAddress: listing.sellerAddress,
        createdAt: listing.createdAt,
        expiresAt: listing.expiresAt,
        status: 'sold',
        buyerAddress: 'test-buyer',
        soldAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> makeOffer({
    required String nftId,
    required double amount,
    required String currency,
    int? expirationDays,
  }) async {
    final offer = YukuOffer(
      id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
      nftId: nftId,
      amount: amount,
      currency: currency,
      buyerAddress: 'test-buyer',
      createdAt: DateTime.now(),
      expiresAt: expirationDays != null 
          ? DateTime.now().add(Duration(days: expirationDays))
          : null,
      status: 'pending',
    );
    
    _myOffers.add(offer);
    _receivedOffers.add(offer);
    return true;
  }

  @override
  Future<bool> acceptOffer(String offerId) async {
    final index = _receivedOffers.indexWhere((o) => o.id == offerId);
    if (index != -1) {
      final offer = _receivedOffers[index];
      _receivedOffers[index] = YukuOffer(
        id: offer.id,
        nftId: offer.nftId,
        amount: offer.amount,
        currency: offer.currency,
        buyerAddress: offer.buyerAddress,
        createdAt: offer.createdAt,
        expiresAt: offer.expiresAt,
        status: 'accepted',
      );
    }
    
    final myIndex = _myOffers.indexWhere((o) => o.id == offerId);
    if (myIndex != -1) {
      final offer = _myOffers[myIndex];
      _myOffers[myIndex] = YukuOffer(
        id: offer.id,
        nftId: offer.nftId,
        amount: offer.amount,
        currency: offer.currency,
        buyerAddress: offer.buyerAddress,
        createdAt: offer.createdAt,
        expiresAt: offer.expiresAt,
        status: 'accepted',
      );
    }
    
    return index != -1;
  }

  @override
  Future<bool> rejectOffer(String offerId) async {
    final index = _receivedOffers.indexWhere((o) => o.id == offerId);
    if (index != -1) {
      final offer = _receivedOffers[index];
      _receivedOffers[index] = YukuOffer(
        id: offer.id,
        nftId: offer.nftId,
        amount: offer.amount,
        currency: offer.currency,
        buyerAddress: offer.buyerAddress,
        createdAt: offer.createdAt,
        expiresAt: offer.expiresAt,
        status: 'rejected',
      );
    }
    
    final myIndex = _myOffers.indexWhere((o) => o.id == offerId);
    if (myIndex != -1) {
      final offer = _myOffers[myIndex];
      _myOffers[myIndex] = YukuOffer(
        id: offer.id,
        nftId: offer.nftId,
        amount: offer.amount,
        currency: offer.currency,
        buyerAddress: offer.buyerAddress,
        createdAt: offer.createdAt,
        expiresAt: offer.expiresAt,
        status: 'rejected',
      );
    }
    
    return index != -1;
  }

  void _setupMockData() {
    // Add some mock listings
    _activeListings.add(YukuListing(
      id: 'listing_1',
      nftId: 'nft_1',
      price: 10.0,
      currency: 'ICP',
      sellerAddress: 'seller_1',
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      expiresAt: DateTime.now().add(Duration(days: 7)),
      status: 'active',
    ));

    // Add some mock offers
    _myOffers.add(YukuOffer(
      id: 'offer_1',
      nftId: 'nft_2',
      amount: 8.0,
      currency: 'ICP',
      buyerAddress: 'buyer_1',
      createdAt: DateTime.now().subtract(Duration(minutes: 30)),
      expiresAt: DateTime.now().add(Duration(days: 3)),
      status: 'pending',
    ));
  }

  // Test helpers
  void addListing(YukuListing listing) {
    _activeListings.add(listing);
  }

  void addOffer(YukuOffer offer) {
    _myOffers.add(offer);
  }

  void clearAll() {
    _activeListings.clear();
    _myListings.clear();
    _myOffers.clear();
    _receivedOffers.clear();
  }
}
