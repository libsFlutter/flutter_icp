// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcpListing _$IcpListingFromJson(Map<String, dynamic> json) => IcpListing(
  id: json['id'] as String,
  tokenId: json['tokenId'] as String,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  seller: json['seller'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IcpListingToJson(IcpListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tokenId': instance.tokenId,
      'price': instance.price,
      'currency': instance.currency,
      'status': instance.status,
      'seller': instance.seller,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
