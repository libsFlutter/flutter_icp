// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_nft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ICPNFT _$ICPNFTFromJson(Map<String, dynamic> json) => ICPNFT(
      id: json['id'] as String,
      tokenId: json['tokenId'] as String,
      canisterId: json['canisterId'] as String,
      metadata: NFTMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      owner: json['owner'] as String,
      creator: json['creator'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as String,
      currentValue: (json['currentValue'] as num?)?.toDouble(),
      valueCurrency: json['valueCurrency'] as String?,
      transactionHistory: (json['transactionHistory'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalProperties:
          json['additionalProperties'] as Map<String, dynamic>? ?? const {},
      icpProperties: ICPNFTProperties.fromJson(
          json['icpProperties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ICPNFTToJson(ICPNFT instance) => <String, dynamic>{
      'id': instance.id,
      'tokenId': instance.tokenId,
      'canisterId': instance.canisterId,
      'metadata': instance.metadata,
      'owner': instance.owner,
      'creator': instance.creator,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': instance.status,
      'currentValue': instance.currentValue,
      'valueCurrency': instance.valueCurrency,
      'transactionHistory': instance.transactionHistory,
      'additionalProperties': instance.additionalProperties,
      'icpProperties': instance.icpProperties,
    };

ICPNFTProperties _$ICPNFTPropertiesFromJson(Map<String, dynamic> json) =>
    ICPNFTProperties(
      isTransferable: json['isTransferable'] as bool,
      isBurnable: json['isBurnable'] as bool,
      isPausable: json['isPausable'] as bool,
      isMintable: json['isMintable'] as bool,
      royaltyPercentage: (json['royaltyPercentage'] as num).toDouble(),
      royaltyRecipient: json['royaltyRecipient'] as String?,
      maxSupply: (json['maxSupply'] as num?)?.toInt(),
      currentSupply: (json['currentSupply'] as num).toInt(),
      metadataMutable: json['metadataMutable'] as bool,
      customProperties:
          json['customProperties'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ICPNFTPropertiesToJson(ICPNFTProperties instance) =>
    <String, dynamic>{
      'isTransferable': instance.isTransferable,
      'isBurnable': instance.isBurnable,
      'isPausable': instance.isPausable,
      'isMintable': instance.isMintable,
      'royaltyPercentage': instance.royaltyPercentage,
      'royaltyRecipient': instance.royaltyRecipient,
      'maxSupply': instance.maxSupply,
      'currentSupply': instance.currentSupply,
      'metadataMutable': instance.metadataMutable,
      'customProperties': instance.customProperties,
    };

ICPNFTCollection _$ICPNFTCollectionFromJson(Map<String, dynamic> json) =>
    ICPNFTCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      symbol: json['symbol'] as String,
      image: json['image'] as String,
      banner: json['banner'] as String?,
      website: json['website'] as String?,
      twitter: json['twitter'] as String?,
      discord: json['discord'] as String?,
      creator: json['creator'] as String,
      canisterId: json['canisterId'] as String,
      properties:
          ICPNFTProperties.fromJson(json['properties'] as Map<String, dynamic>),
      totalSupply: (json['totalSupply'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ICPNFTCollectionToJson(ICPNFTCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'symbol': instance.symbol,
      'image': instance.image,
      'banner': instance.banner,
      'website': instance.website,
      'twitter': instance.twitter,
      'discord': instance.discord,
      'creator': instance.creator,
      'canisterId': instance.canisterId,
      'properties': instance.properties,
      'totalSupply': instance.totalSupply,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': instance.status,
    };
