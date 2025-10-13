import 'package:json_annotation/json_annotation.dart';

part 'icp_nft.g.dart';

/// Represents an NFT on the Internet Computer Protocol (ICP) blockchain
@JsonSerializable()
class ICPNFT {
  /// Unique identifier for the NFT
  final String id;

  /// Name of the NFT
  final String name;

  /// Description of the NFT
  final String description;

  /// URL to the NFT's image or media
  final String imageUrl;

  /// The owner's principal ID
  final String owner;

  /// Collection information
  final ICPNFTCollection? collection;

  /// Custom properties/metadata
  final Map<String, dynamic>? properties;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  ICPNFT({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.owner,
    this.collection,
    this.properties,
    this.createdAt,
    this.updatedAt,
  });

  /// Create an ICPNFT from JSON
  factory ICPNFT.fromJson(Map<String, dynamic> json) => _$ICPNFTFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ICPNFTToJson(this);
}

/// Represents an NFT collection on ICP
@JsonSerializable()
class ICPNFTCollection {
  /// Collection ID
  final String id;

  /// Collection name
  final String name;

  /// Collection description
  final String? description;

  /// Collection image URL
  final String? imageUrl;

  /// Creator principal ID
  final String creator;

  /// Number of items in the collection
  final int itemCount;

  ICPNFTCollection({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.creator,
    this.itemCount = 0,
  });

  /// Create an ICPNFTCollection from JSON
  factory ICPNFTCollection.fromJson(Map<String, dynamic> json) =>
      _$ICPNFTCollectionFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ICPNFTCollectionToJson(this);
}

/// NFT properties model
@JsonSerializable()
class ICPNFTProperties {
  /// List of attributes
  final List<Map<String, dynamic>>? attributes;

  /// External URL
  final String? externalUrl;

  /// Animation URL (for animated NFTs)
  final String? animationUrl;

  /// Background color (hex)
  final String? backgroundColor;

  ICPNFTProperties({
    this.attributes,
    this.externalUrl,
    this.animationUrl,
    this.backgroundColor,
  });

  /// Create ICPNFTProperties from JSON
  factory ICPNFTProperties.fromJson(Map<String, dynamic> json) =>
      _$ICPNFTPropertiesFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ICPNFTPropertiesToJson(this);
}
