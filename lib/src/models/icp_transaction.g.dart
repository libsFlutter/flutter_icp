// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icp_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcpTransaction _$IcpTransactionFromJson(Map<String, dynamic> json) =>
    IcpTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      from: json['from'] as String?,
      to: json['to'] as String?,
      hash: json['hash'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$IcpTransactionToJson(IcpTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'from': instance.from,
      'to': instance.to,
      'hash': instance.hash,
      'data': instance.data,
    };
