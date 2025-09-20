import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_nft/flutter_nft.dart';
import '../core/icp_types.dart';

part 'icp_nft.g.dart';

/// ICP-specific NFT model
@JsonSerializable()
class ICPNFT extends Equatable {
  /// Unique identifier of the NFT
  final String id;

  /// Token ID on the ICP canister
  final String tokenId;

  /// Canister ID (equivalent to contract address)
  final String canisterId;

  /// NFT metadata
  final NFTMetadata metadata;

  /// Current owner address (ICP principal)
  final String owner;

  /// Creator address (ICP principal)
  final String creator;

  /// When the NFT was created
  final DateTime createdAt;

  /// When the NFT was last updated
  final DateTime updatedAt;

  /// Current status of the NFT
  final String status;

  /// Current market value (if available)
  final double? currentValue;

  /// Currency of the current value
  final String? valueCurrency;

  /// Transaction history
  final List<String> transactionHistory;

  /// Additional properties specific to ICP
  final Map<String, dynamic> additionalProperties;

  /// ICP-specific properties
  final ICPNFTProperties icpProperties;

  const ICPNFT({
    required this.id,
    required this.tokenId,
    required this.canisterId,
    required this.metadata,
    required this.owner,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.currentValue,
    this.valueCurrency,
    required this.transactionHistory,
    this.additionalProperties = const {},
    required this.icpProperties,
  });

  /// Create ICPNFT from JSON
  factory ICPNFT.fromJson(Map<String, dynamic> json) => _$ICPNFTFromJson(json);

  /// Convert ICPNFT to JSON
  Map<String, dynamic> toJson() => _$ICPNFTToJson(this);

  /// Create a copy of the ICPNFT with updated fields
  ICPNFT copyWith({
    String? id,
    String? tokenId,
    String? canisterId,
    NFTMetadata? metadata,
    String? owner,
    String? creator,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    double? currentValue,
    String? valueCurrency,
    List<String>? transactionHistory,
    Map<String, dynamic>? additionalProperties,
    ICPNFTProperties? icpProperties,
  }) {
    return ICPNFT(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      canisterId: canisterId ?? this.canisterId,
      metadata: metadata ?? this.metadata,
      owner: owner ?? this.owner,
      creator: creator ?? this.creator,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      currentValue: currentValue ?? this.currentValue,
      valueCurrency: valueCurrency ?? this.valueCurrency,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      additionalProperties: additionalProperties ?? this.additionalProperties,
      icpProperties: icpProperties ?? this.icpProperties,
    );
  }

  /// Check if NFT is owned by the given address
  bool isOwnedBy(String address) => owner.toLowerCase() == address.toLowerCase();

  /// Check if NFT is created by the given address
  bool isCreatedBy(String address) => creator.toLowerCase() == address.toLowerCase();

  /// Get formatted current value
  String get formattedValue {
    if (currentValue == null || valueCurrency == null) return 'N/A';
    return '${currentValue!.toStringAsFixed(4)} $valueCurrency';
  }

  /// Check if NFT is transferable
  bool get isTransferable => icpProperties.isTransferable;

  /// Check if NFT is burnable
  bool get isBurnable => icpProperties.isBurnable;

  /// Check if NFT is pausable
  bool get isPausable => icpProperties.isPausable;

  /// Get ICP principal of owner
  ICPPrincipal get ownerPrincipal => ICPPrincipal(value: owner);

  /// Get ICP principal of creator
  ICPPrincipal get creatorPrincipal => ICPPrincipal(value: creator);

  @override
  List<Object?> get props => [
        id,
        tokenId,
        canisterId,
        metadata,
        owner,
        creator,
        createdAt,
        updatedAt,
        status,
        currentValue,
        valueCurrency,
        transactionHistory,
        additionalProperties,
        icpProperties,
      ];
}

/// ICP-specific NFT properties
@JsonSerializable()
class ICPNFTProperties extends Equatable {
  /// Whether the NFT is transferable
  final bool isTransferable;

  /// Whether the NFT is burnable
  final bool isBurnable;

  /// Whether the NFT is pausable
  final bool isPausable;

  /// Whether the NFT is mintable
  final bool isMintable;

  /// Royalty percentage (0-100)
  final double royaltyPercentage;

  /// Royalty recipient address
  final String? royaltyRecipient;

  /// Maximum supply (null for unlimited)
  final int? maxSupply;

  /// Current supply
  final int currentSupply;

  /// Whether metadata is mutable
  final bool metadataMutable;

  /// Custom properties
  final Map<String, dynamic> customProperties;

  const ICPNFTProperties({
    required this.isTransferable,
    required this.isBurnable,
    required this.isPausable,
    required this.isMintable,
    required this.royaltyPercentage,
    this.royaltyRecipient,
    this.maxSupply,
    required this.currentSupply,
    required this.metadataMutable,
    this.customProperties = const {},
  });

  /// Create ICPNFTProperties from JSON
  factory ICPNFTProperties.fromJson(Map<String, dynamic> json) => _$ICPNFTPropertiesFromJson(json);

  /// Convert ICPNFTProperties to JSON
  Map<String, dynamic> toJson() => _$ICPNFTPropertiesToJson(this);

  /// Create a copy with updated fields
  ICPNFTProperties copyWith({
    bool? isTransferable,
    bool? isBurnable,
    bool? isPausable,
    bool? isMintable,
    double? royaltyPercentage,
    String? royaltyRecipient,
    int? maxSupply,
    int? currentSupply,
    bool? metadataMutable,
    Map<String, dynamic>? customProperties,
  }) {
    return ICPNFTProperties(
      isTransferable: isTransferable ?? this.isTransferable,
      isBurnable: isBurnable ?? this.isBurnable,
      isPausable: isPausable ?? this.isPausable,
      isMintable: isMintable ?? this.isMintable,
      royaltyPercentage: royaltyPercentage ?? this.royaltyPercentage,
      royaltyRecipient: royaltyRecipient ?? this.royaltyRecipient,
      maxSupply: maxSupply ?? this.maxSupply,
      currentSupply: currentSupply ?? this.currentSupply,
      metadataMutable: metadataMutable ?? this.metadataMutable,
      customProperties: customProperties ?? this.customProperties,
    );
  }

  /// Get formatted royalty percentage
  String get formattedRoyalty => '${royaltyPercentage.toStringAsFixed(2)}%';

  /// Check if supply is limited
  bool get hasLimitedSupply => maxSupply != null;

  /// Check if max supply is reached
  bool get isMaxSupplyReached => maxSupply != null && currentSupply >= maxSupply!;

  /// Get remaining supply
  int? get remainingSupply => maxSupply != null ? maxSupply! - currentSupply : null;

  @override
  List<Object?> get props => [
        isTransferable,
        isBurnable,
        isPausable,
        isMintable,
        royaltyPercentage,
        royaltyRecipient,
        maxSupply,
        currentSupply,
        metadataMutable,
        customProperties,
      ];
}

/// ICP NFT collection information
@JsonSerializable()
class ICPNFTCollection extends Equatable {
  /// Collection ID
  final String id;

  /// Collection name
  final String name;

  /// Collection description
  final String description;

  /// Collection symbol
  final String symbol;

  /// Collection image
  final String image;

  /// Collection banner
  final String? banner;

  /// Collection website
  final String? website;

  /// Collection Twitter
  final String? twitter;

  /// Collection Discord
  final String? discord;

  /// Collection creator
  final String creator;

  /// Collection canister ID
  final String canisterId;

  /// Collection properties
  final ICPNFTProperties properties;

  /// Total supply
  final int totalSupply;

  /// When the collection was created
  final DateTime createdAt;

  /// When the collection was last updated
  final DateTime updatedAt;

  /// Collection status
  final String status;

  const ICPNFTCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.symbol,
    required this.image,
    this.banner,
    this.website,
    this.twitter,
    this.discord,
    required this.creator,
    required this.canisterId,
    required this.properties,
    required this.totalSupply,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// Create ICPNFTCollection from JSON
  factory ICPNFTCollection.fromJson(Map<String, dynamic> json) => _$ICPNFTCollectionFromJson(json);

  /// Convert ICPNFTCollection to JSON
  Map<String, dynamic> toJson() => _$ICPNFTCollectionToJson(this);

  /// Create a copy with updated fields
  ICPNFTCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? symbol,
    String? image,
    String? banner,
    String? website,
    String? twitter,
    String? discord,
    String? creator,
    String? canisterId,
    ICPNFTProperties? properties,
    int? totalSupply,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return ICPNFTCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symbol: symbol ?? this.symbol,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      website: website ?? this.website,
      twitter: twitter ?? this.twitter,
      discord: discord ?? this.discord,
      creator: creator ?? this.creator,
      canisterId: canisterId ?? this.canisterId,
      properties: properties ?? this.properties,
      totalSupply: totalSupply ?? this.totalSupply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  /// Check if collection is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if collection is paused
  bool get isPaused => status.toLowerCase() == 'paused';

  /// Get creator principal
  ICPPrincipal get creatorPrincipal => ICPPrincipal(value: creator);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        symbol,
        image,
        banner,
        website,
        twitter,
        discord,
        creator,
        canisterId,
        properties,
        totalSupply,
        createdAt,
        updatedAt,
        status,
      ];
}
