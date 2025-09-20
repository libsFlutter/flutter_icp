import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YukuListing {
  final String id;
  final String nftId;
  final double price;
  final String currency; // 'ICP', 'WICP', 'USD'
  final String sellerAddress;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'active', 'sold', 'cancelled'
  final String? buyerAddress;
  final DateTime? soldAt;

  YukuListing({
    required this.id,
    required this.nftId,
    required this.price,
    required this.currency,
    required this.sellerAddress,
    required this.createdAt,
    this.expiresAt,
    required this.status,
    this.buyerAddress,
    this.soldAt,
  });

  factory YukuListing.fromJson(Map<String, dynamic> json) {
    return YukuListing(
      id: json['id'],
      nftId: json['nftId'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      sellerAddress: json['sellerAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status: json['status'],
      buyerAddress: json['buyerAddress'],
      soldAt: json['soldAt'] != null ? DateTime.parse(json['soldAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nftId': nftId,
      'price': price,
      'currency': currency,
      'sellerAddress': sellerAddress,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'buyerAddress': buyerAddress,
      'soldAt': soldAt?.toIso8601String(),
    };
  }
}

class YukuOffer {
  final String id;
  final String nftId;
  final double amount;
  final String currency;
  final String buyerAddress;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'pending', 'accepted', 'rejected'

  YukuOffer({
    required this.id,
    required this.nftId,
    required this.amount,
    required this.currency,
    required this.buyerAddress,
    required this.createdAt,
    this.expiresAt,
    required this.status,
  });

  factory YukuOffer.fromJson(Map<String, dynamic> json) {
    return YukuOffer(
      id: json['id'],
      nftId: json['nftId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      buyerAddress: json['buyerAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nftId': nftId,
      'amount': amount,
      'currency': currency,
      'buyerAddress': buyerAddress,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
    };
  }
}

class YukuService extends ChangeNotifier {
  static const String _yukuApiUrl = 'https://yuku.app/api';

  List<YukuListing> _activeListings = [];
  List<YukuListing> _myListings = [];
  List<YukuOffer> _myOffers = [];
  List<YukuOffer> _receivedOffers = [];
  bool _isLoading = false;
  String? _error;

  List<YukuListing> get activeListings => _activeListings;
  List<YukuListing> get myListings => _myListings;
  List<YukuOffer> get myOffers => _myOffers;
  List<YukuOffer> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for prototype
  final List<Map<String, dynamic>> _mockListings = [
    {
      'id': 'listing_001',
      'nftId': 'nft_TL001',
      'price': 1500.0,
      'currency': 'ICP',
      'sellerAddress': 'user456',
      'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(days: 28)).toIso8601String(),
      'status': 'active',
    },
    {
      'id': 'listing_002',
      'nftId': 'nft_TL002',
      'price': 2200.0,
      'currency': 'ICP',
      'sellerAddress': 'user789',
      'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(days: 29)).toIso8601String(),
      'status': 'active',
    },
  ];

  final List<Map<String, dynamic>> _mockOffers = [
    {
      'id': 'offer_001',
      'nftId': 'nft_TL001',
      'amount': 1400.0,
      'currency': 'ICP',
      'buyerAddress': 'user123',
      'createdAt':
          DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      'status': 'pending',
    },
  ];

  Future<void> initialize() async {
    await loadActiveListings();
    await loadMyListings();
    await loadMyOffers();
    await loadReceivedOffers();
  }

  Future<void> loadActiveListings() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));

      _activeListings =
          _mockListings.map((data) => YukuListing.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load active listings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyListings() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 400));

      _myListings = _mockListings
          .where((data) => data['sellerAddress'] == 'user123')
          .map((data) => YukuListing.fromJson(data))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load my listings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyOffers() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 300));

      _myOffers = _mockOffers.map((data) => YukuOffer.fromJson(data)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load my offers: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReceivedOffers() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 350));

      _receivedOffers = _mockOffers
          .map((data) => YukuOffer.fromJson({
                ...data,
                'buyerAddress': 'user456', // Different buyer
              }))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load received offers: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createListing({
    required String nftId,
    required double price,
    required String currency,
    int? expirationDays,
  }) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_yukuApiUrl/listings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nftId': nftId,
          'price': price,
          'currency': currency,
          'expirationDays': expirationDays,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final listing = YukuListing.fromJson(data['listing']);

        _myListings.add(listing);
        _activeListings.add(listing);

        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create listing: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create listing: $e';
      // Fallback to mock data for development
      final listing = YukuListing(
        id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
        nftId: nftId,
        price: price,
        currency: currency,
        sellerAddress: 'user123',
        createdAt: DateTime.now(),
        expiresAt: expirationDays != null
            ? DateTime.now().add(Duration(days: expirationDays))
            : null,
        status: 'active',
      );

      _myListings.add(listing);
      _activeListings.add(listing);
      notifyListeners();
      return true;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelListing(String listingId) async {
    _setLoading(true);
    try {
      final response = await http.delete(
        Uri.parse('$_yukuApiUrl/listings/$listingId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _myListings.removeWhere((listing) => listing.id == listingId);
        _activeListings.removeWhere((listing) => listing.id == listingId);

        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to cancel listing: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Failed to cancel listing: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> buyNFT(String listingId) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 3));

      final listingIndex =
          _activeListings.indexWhere((listing) => listing.id == listingId);
      if (listingIndex != -1) {
        final listing = _activeListings[listingIndex];
        final updatedListing = YukuListing(
          id: listing.id,
          nftId: listing.nftId,
          price: listing.price,
          currency: listing.currency,
          sellerAddress: listing.sellerAddress,
          createdAt: listing.createdAt,
          expiresAt: listing.expiresAt,
          status: 'sold',
          buyerAddress: 'user123',
          soldAt: DateTime.now(),
        );

        _activeListings[listingIndex] = updatedListing;

        // Remove from active listings
        _activeListings.removeWhere((listing) => listing.id == listingId);

        _error = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to buy NFT: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> makeOffer({
    required String nftId,
    required double amount,
    required String currency,
    int? expirationDays,
  }) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final offer = YukuOffer(
        id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
        nftId: nftId,
        amount: amount,
        currency: currency,
        buyerAddress: 'user123',
        createdAt: DateTime.now(),
        expiresAt: expirationDays != null
            ? DateTime.now().add(Duration(days: expirationDays))
            : null,
        status: 'pending',
      );

      _myOffers.add(offer);

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to make offer: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptOffer(String offerId) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final offerIndex =
          _receivedOffers.indexWhere((offer) => offer.id == offerId);
      if (offerIndex != -1) {
        final offer = _receivedOffers[offerIndex];
        final updatedOffer = YukuOffer(
          id: offer.id,
          nftId: offer.nftId,
          amount: offer.amount,
          currency: offer.currency,
          buyerAddress: offer.buyerAddress,
          createdAt: offer.createdAt,
          expiresAt: offer.expiresAt,
          status: 'accepted',
        );

        _receivedOffers[offerIndex] = updatedOffer;

        _error = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to accept offer: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectOffer(String offerId) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final offerIndex =
          _receivedOffers.indexWhere((offer) => offer.id == offerId);
      if (offerIndex != -1) {
        final offer = _receivedOffers[offerIndex];
        final updatedOffer = YukuOffer(
          id: offer.id,
          nftId: offer.nftId,
          amount: offer.amount,
          currency: offer.currency,
          buyerAddress: offer.buyerAddress,
          createdAt: offer.createdAt,
          expiresAt: offer.expiresAt,
          status: 'rejected',
        );

        _receivedOffers[offerIndex] = updatedOffer;

        _error = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to reject offer: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get active listings (alias for loadActiveListings)
  Future<List<YukuListing>> getActiveListings() async {
    await loadActiveListings();
    return _activeListings;
  }

  /// Get my listings (alias for loadMyListings)
  Future<List<YukuListing>> getMyListings() async {
    await loadMyListings();
    return _myListings;
  }

  /// Get my offers (alias for loadMyOffers)
  Future<List<YukuOffer>> getMyOffers() async {
    await loadMyOffers();
    return _myOffers;
  }

  /// Get received offers (alias for loadReceivedOffers)
  Future<List<YukuOffer>> getReceivedOffers() async {
    await loadReceivedOffers();
    return _receivedOffers;
  }
}
