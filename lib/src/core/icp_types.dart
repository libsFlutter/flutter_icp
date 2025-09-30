import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_yuku/flutter_yuku.dart';

part 'icp_types.g.dart';

/// ICP-specific transaction types
enum ICPTransactionType {
  transfer,
  mint,
  burn,
  approve,
  list,
  buy,
  makeOffer,
  acceptOffer,
  cancelListing,
  cancelOffer,
}

/// Blockchain network constants
class BlockchainNetwork {
  static const icp = 'icp';
}

/// Listing status constants
class ListingStatus {
  static const active = 'active';
  static const inactive = 'inactive';
  static const sold = 'sold';
}

/// Offer status constants
class OfferStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
}

/// Transaction model for ICP
@JsonSerializable()
class Transaction extends Equatable {
  final String id;
  final String type;
  final String from;
  final String to;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? blockHeight;
  final double? fee;
  final String? error;

  const Transaction({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.status,
    required this.timestamp,
    this.blockHeight,
    this.fee,
    this.error,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      blockHeight: json['blockHeight'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'from': from,
      'to': to,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'blockHeight': blockHeight,
      'fee': fee,
      'error': error,
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    from,
    to,
    amount,
    currency,
    status,
    timestamp,
    blockHeight,
    fee,
    error,
  ];
}

/// Network status model
@JsonSerializable()
class NetworkStatus extends Equatable {
  final String name;
  final String url;
  final bool isOnline;
  final DateTime lastChecked;
  final Map<String, dynamic> metrics;

  const NetworkStatus({
    required this.name,
    required this.url,
    required this.isOnline,
    required this.lastChecked,
    this.metrics = const {},
  });

  factory NetworkStatus.fromJson(Map<String, dynamic> json) {
    return NetworkStatus(
      name: json['name'] as String,
      url: json['url'] as String,
      isOnline: json['isOnline'] as bool,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      metrics: Map<String, dynamic>.from(json['metrics'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'isOnline': isOnline,
      'lastChecked': lastChecked.toIso8601String(),
      'metrics': metrics,
    };
  }

  @override
  List<Object?> get props => [name, url, isOnline, lastChecked, metrics];
}

/// Canister info model
@JsonSerializable()
class CanisterInfo extends Equatable {
  final String id;
  final String name;
  final String description;
  final String controller;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const CanisterInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.controller,
    required this.isActive,
    this.metadata = const {},
  });

  factory CanisterInfo.fromJson(Map<String, dynamic> json) {
    return CanisterInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      controller: json['controller'] as String,
      isActive: json['isActive'] as bool,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'controller': controller,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    controller,
    isActive,
    metadata,
  ];
}

/// ICP canister types
enum ICPCanisterType { ledger, nft, marketplace, registry, custom }

/// ICP principal ID representation
@JsonSerializable()
class ICPPrincipal extends Equatable {
  final String value;
  final String? displayName;

  const ICPPrincipal({required this.value, this.displayName});

  factory ICPPrincipal.fromJson(Map<String, dynamic> json) =>
      _$ICPPrincipalFromJson(json);
  Map<String, dynamic> toJson() => _$ICPPrincipalToJson(this);

  @override
  List<Object?> get props => [value, displayName];

  /// Check if principal is valid
  bool get isValid {
    // Basic validation for ICP principal
    if (value.length < 10 || value.length > 63) return false;
    final base32Pattern = RegExp(r'^[2-7a-z]+$');
    return base32Pattern.hasMatch(value.toLowerCase());
  }

  /// Get formatted principal for display
  String get displayValue {
    if (value.length <= 10) return value;
    return '${value.substring(0, 5)}...${value.substring(value.length - 5)}';
  }
}

/// ICP account ID representation
@JsonSerializable()
class ICPAccountId extends Equatable {
  final String value;
  final ICPPrincipal principal;

  const ICPAccountId({required this.value, required this.principal});

  factory ICPAccountId.fromJson(Map<String, dynamic> json) =>
      _$ICPAccountIdFromJson(json);
  Map<String, dynamic> toJson() => _$ICPAccountIdToJson(this);

  @override
  List<Object?> get props => [value, principal];

  /// Get formatted account ID for display
  String get displayValue {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }
}

/// ICP canister information
@JsonSerializable()
class ICPCanister extends Equatable {
  final String id;
  final ICPCanisterType type;
  final String name;
  final String description;
  final ICPPrincipal controller;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const ICPCanister({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.controller,
    required this.isActive,
    this.metadata = const {},
  });

  factory ICPCanister.fromJson(Map<String, dynamic> json) =>
      _$ICPCanisterFromJson(json);
  Map<String, dynamic> toJson() => _$ICPCanisterToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    name,
    description,
    controller,
    isActive,
    metadata,
  ];
}

/// ICP network configuration
@JsonSerializable()
class ICPNetworkConfig extends Equatable {
  final String name;
  final String url;
  final bool isTestnet;
  final Map<String, String> canisterIds;
  final Map<String, dynamic> additionalParams;

  const ICPNetworkConfig({
    required this.name,
    required this.url,
    required this.isTestnet,
    this.canisterIds = const {},
    this.additionalParams = const {},
  });

  factory ICPNetworkConfig.fromJson(Map<String, dynamic> json) =>
      _$ICPNetworkConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ICPNetworkConfigToJson(this);

  /// Mainnet configuration
  static const mainnet = ICPNetworkConfig(
    name: 'ICP Mainnet',
    url: 'https://ic0.app',
    isTestnet: false,
    canisterIds: {
      'ledger': 'ryjl3-tyaaa-aaaaa-aaaba-cai',
      'registry': 'rdmx6-jaaaa-aaaaa-aaadq-cai',
    },
  );

  /// Testnet configuration
  static const testnet = ICPNetworkConfig(
    name: 'ICP Testnet',
    url: 'https://ic0.testnet.app',
    isTestnet: true,
    canisterIds: {
      'ledger': 'ryjl3-tyaaa-aaaaa-aaaba-cai',
      'registry': 'rdmx6-jaaaa-aaaaa-aaadq-cai',
    },
  );

  @override
  List<Object?> get props => [
    name,
    url,
    isTestnet,
    canisterIds,
    additionalParams,
  ];
}

/// ICP transaction request
@JsonSerializable()
class ICPTransactionRequest extends Equatable {
  final ICPTransactionType type;
  final ICPPrincipal from;
  final ICPPrincipal to;
  final double amount;
  final String currency;
  final String? memo;
  final Map<String, dynamic> params;
  final String? canisterId;

  const ICPTransactionRequest({
    required this.type,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    this.memo,
    this.params = const {},
    this.canisterId,
  });

  factory ICPTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$ICPTransactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ICPTransactionRequestToJson(this);

  @override
  List<Object?> get props => [
    type,
    from,
    to,
    amount,
    currency,
    memo,
    params,
    canisterId,
  ];
}

/// ICP transaction result
@JsonSerializable()
class ICPTransactionResult extends Equatable {
  final String transactionId;
  final ICPTransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? blockHeight;
  final double? fee;
  final String? error;

  const ICPTransactionResult({
    required this.transactionId,
    required this.type,
    required this.status,
    required this.timestamp,
    this.blockHeight,
    this.fee,
    this.error,
  });

  factory ICPTransactionResult.fromJson(Map<String, dynamic> json) =>
      _$ICPTransactionResultFromJson(json);
  Map<String, dynamic> toJson() => _$ICPTransactionResultToJson(this);

  @override
  List<Object?> get props => [
    transactionId,
    type,
    status,
    timestamp,
    blockHeight,
    fee,
    error,
  ];
}

/// ICP balance information
@JsonSerializable()
class ICPBalance extends Equatable {
  final String currency;
  final double amount;
  final double? usdValue;
  final DateTime lastUpdated;

  const ICPBalance({
    required this.currency,
    required this.amount,
    this.usdValue,
    required this.lastUpdated,
  });

  factory ICPBalance.fromJson(Map<String, dynamic> json) =>
      _$ICPBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$ICPBalanceToJson(this);

  /// Get formatted balance
  String get formattedAmount {
    switch (currency) {
      case 'ICP':
        return '${amount.toStringAsFixed(4)} ICP';
      case 'WICP':
        return '${amount.toStringAsFixed(4)} WICP';
      default:
        return '${amount.toStringAsFixed(4)} $currency';
    }
  }

  /// Get formatted USD value
  String get formattedUsdValue {
    if (usdValue == null) return 'N/A';
    return '\$${usdValue!.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [currency, amount, usdValue, lastUpdated];
}

/// ICP wallet information
@JsonSerializable()
class ICPWalletInfo extends Equatable {
  final ICPPrincipal principal;
  final ICPAccountId accountId;
  final Map<String, ICPBalance> balances;
  final List<ICPTransactionResult> recentTransactions;
  final DateTime lastUpdated;

  const ICPWalletInfo({
    required this.principal,
    required this.accountId,
    required this.balances,
    required this.recentTransactions,
    required this.lastUpdated,
  });

  factory ICPWalletInfo.fromJson(Map<String, dynamic> json) =>
      _$ICPWalletInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ICPWalletInfoToJson(this);

  /// Get total USD value
  double get totalUsdValue {
    return balances.values
        .where((balance) => balance.usdValue != null)
        .fold(0.0, (sum, balance) => sum + (balance.usdValue ?? 0));
  }

  /// Get formatted total USD value
  String get formattedTotalUsdValue {
    return '\$${totalUsdValue.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
    principal,
    accountId,
    balances,
    recentTransactions,
    lastUpdated,
  ];
}
