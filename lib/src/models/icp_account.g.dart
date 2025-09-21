// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ICPAccount _$ICPAccountFromJson(Map<String, dynamic> json) => ICPAccount(
      principal: json['principal'] as String,
      subAccount: json['subAccount'] as String?,
      balance: BigInt.parse(json['balance'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ICPAccountToJson(ICPAccount instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'subAccount': instance.subAccount,
      'balance': instance.balance.toString(),
      'metadata': instance.metadata,
    };

ICPTransaction _$ICPTransactionFromJson(Map<String, dynamic> json) =>
    ICPTransaction(
      id: json['id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: BigInt.parse(json['amount'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$ICPTransactionToJson(ICPTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from': instance.from,
      'to': instance.to,
      'amount': instance.amount.toString(),
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'memo': instance.memo,
    };

ICPCanisterInfo _$ICPCanisterInfoFromJson(Map<String, dynamic> json) =>
    ICPCanisterInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      controllers: (json['controllers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ICPCanisterInfoToJson(ICPCanisterInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'metadata': instance.metadata,
      'controllers': instance.controllers,
    };
