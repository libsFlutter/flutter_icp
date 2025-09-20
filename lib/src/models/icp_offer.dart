import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icp_offer.g.dart';

/// Represents an ICP NFT offer
@JsonSerializable()
class IcpOffer extends Equatable {
  /// Offer ID
  final String id;

  /// NFT token ID
  final String tokenId;

  /// Offer amount
  final double amount;

  /// Currency of the offer
  final String currency;

  /// Offer status
  final String status;

  /// Offerer address
  final String offerer;

  /// Timestamp when offer was created
  final DateTime createdAt;

  /// Timestamp when offer expires (if applicable)
  final DateTime? expiresAt;

  /// Additional offer metadata
  final Map<String, dynamic>? metadata;

  const IcpOffer({
    required this.id,
    required this.tokenId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.offerer,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory IcpOffer.fromJson(Map<String, dynamic> json) =>
      _$IcpOfferFromJson(json);

  Map<String, dynamic> toJson() => _$IcpOfferToJson(this);

  @override
  List<Object?> get props => [
        id,
        tokenId,
        amount,
        currency,
        status,
        offerer,
        createdAt,
        expiresAt,
        metadata,
      ];
}
