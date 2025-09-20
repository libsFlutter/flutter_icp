import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icp_listing.g.dart';

/// Represents an ICP NFT listing
@JsonSerializable()
class IcpListing extends Equatable {
  /// Listing ID
  final String id;

  /// NFT token ID
  final String tokenId;

  /// Listing price
  final double price;

  /// Currency of the listing
  final String currency;

  /// Listing status
  final String status;

  /// Seller address
  final String seller;

  /// Timestamp when listing was created
  final DateTime createdAt;

  /// Timestamp when listing expires (if applicable)
  final DateTime? expiresAt;

  /// Additional listing metadata
  final Map<String, dynamic>? metadata;

  const IcpListing({
    required this.id,
    required this.tokenId,
    required this.price,
    required this.currency,
    required this.status,
    required this.seller,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory IcpListing.fromJson(Map<String, dynamic> json) =>
      _$IcpListingFromJson(json);

  Map<String, dynamic> toJson() => _$IcpListingToJson(this);

  @override
  List<Object?> get props => [
        id,
        tokenId,
        price,
        currency,
        status,
        seller,
        createdAt,
        expiresAt,
        metadata,
      ];
}
