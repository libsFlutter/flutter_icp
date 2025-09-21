// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ICPPrincipal _$ICPPrincipalFromJson(Map<String, dynamic> json) => ICPPrincipal(
  value: json['value'] as String,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$ICPPrincipalToJson(ICPPrincipal instance) =>
    <String, dynamic>{
      'value': instance.value,
      'displayName': instance.displayName,
    };

ICPAccountId _$ICPAccountIdFromJson(Map<String, dynamic> json) => ICPAccountId(
  value: json['value'] as String,
  principal: ICPPrincipal.fromJson(json['principal'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ICPAccountIdToJson(ICPAccountId instance) =>
    <String, dynamic>{'value': instance.value, 'principal': instance.principal};

ICPCanister _$ICPCanisterFromJson(Map<String, dynamic> json) => ICPCanister(
  id: json['id'] as String,
  type: $enumDecode(_$ICPCanisterTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  controller: ICPPrincipal.fromJson(json['controller'] as Map<String, dynamic>),
  isActive: json['isActive'] as bool,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ICPCanisterToJson(ICPCanister instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ICPCanisterTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'controller': instance.controller,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

const _$ICPCanisterTypeEnumMap = {
  ICPCanisterType.ledger: 'ledger',
  ICPCanisterType.nft: 'nft',
  ICPCanisterType.marketplace: 'marketplace',
  ICPCanisterType.registry: 'registry',
  ICPCanisterType.custom: 'custom',
};

ICPNetworkConfig _$ICPNetworkConfigFromJson(Map<String, dynamic> json) =>
    ICPNetworkConfig(
      name: json['name'] as String,
      url: json['url'] as String,
      isTestnet: json['isTestnet'] as bool,
      canisterIds:
          (json['canisterIds'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      additionalParams:
          json['additionalParams'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ICPNetworkConfigToJson(ICPNetworkConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'isTestnet': instance.isTestnet,
      'canisterIds': instance.canisterIds,
      'additionalParams': instance.additionalParams,
    };

ICPTransactionRequest _$ICPTransactionRequestFromJson(
  Map<String, dynamic> json,
) => ICPTransactionRequest(
  type: $enumDecode(_$ICPTransactionTypeEnumMap, json['type']),
  from: ICPPrincipal.fromJson(json['from'] as Map<String, dynamic>),
  to: ICPPrincipal.fromJson(json['to'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  memo: json['memo'] as String?,
  params: json['params'] as Map<String, dynamic>? ?? const {},
  canisterId: json['canisterId'] as String?,
);

Map<String, dynamic> _$ICPTransactionRequestToJson(
  ICPTransactionRequest instance,
) => <String, dynamic>{
  'type': _$ICPTransactionTypeEnumMap[instance.type]!,
  'from': instance.from,
  'to': instance.to,
  'amount': instance.amount,
  'currency': instance.currency,
  'memo': instance.memo,
  'params': instance.params,
  'canisterId': instance.canisterId,
};

const _$ICPTransactionTypeEnumMap = {
  ICPTransactionType.transfer: 'transfer',
  ICPTransactionType.mint: 'mint',
  ICPTransactionType.burn: 'burn',
  ICPTransactionType.approve: 'approve',
  ICPTransactionType.list: 'list',
  ICPTransactionType.buy: 'buy',
  ICPTransactionType.makeOffer: 'makeOffer',
  ICPTransactionType.acceptOffer: 'acceptOffer',
  ICPTransactionType.cancelListing: 'cancelListing',
  ICPTransactionType.cancelOffer: 'cancelOffer',
};

ICPTransactionResult _$ICPTransactionResultFromJson(
  Map<String, dynamic> json,
) => ICPTransactionResult(
  transactionId: json['transactionId'] as String,
  type: $enumDecode(_$ICPTransactionTypeEnumMap, json['type']),
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  blockHeight: json['blockHeight'] as String?,
  fee: (json['fee'] as num?)?.toDouble(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ICPTransactionResultToJson(
  ICPTransactionResult instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'type': _$ICPTransactionTypeEnumMap[instance.type]!,
  'status': _$TransactionStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'blockHeight': instance.blockHeight,
  'fee': instance.fee,
  'error': instance.error,
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.confirmed: 'confirmed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
};

ICPBalance _$ICPBalanceFromJson(Map<String, dynamic> json) => ICPBalance(
  currency: json['currency'] as String,
  amount: (json['amount'] as num).toDouble(),
  usdValue: (json['usdValue'] as num?)?.toDouble(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$ICPBalanceToJson(ICPBalance instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'amount': instance.amount,
      'usdValue': instance.usdValue,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

ICPWalletInfo _$ICPWalletInfoFromJson(
  Map<String, dynamic> json,
) => ICPWalletInfo(
  principal: ICPPrincipal.fromJson(json['principal'] as Map<String, dynamic>),
  accountId: ICPAccountId.fromJson(json['accountId'] as Map<String, dynamic>),
  balances: (json['balances'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, ICPBalance.fromJson(e as Map<String, dynamic>)),
  ),
  recentTransactions: (json['recentTransactions'] as List<dynamic>)
      .map((e) => ICPTransactionResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$ICPWalletInfoToJson(ICPWalletInfo instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'accountId': instance.accountId,
      'balances': instance.balances,
      'recentTransactions': instance.recentTransactions,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
