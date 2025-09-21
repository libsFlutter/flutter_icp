// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcpOffer _$IcpOfferFromJson(Map<String, dynamic> json) => IcpOffer(
  id: json['id'] as String,
  tokenId: json['tokenId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  offerer: json['offerer'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IcpOfferToJson(IcpOffer instance) => <String, dynamic>{
  'id': instance.id,
  'tokenId': instance.tokenId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'offerer': instance.offerer,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'metadata': instance.metadata,
};
