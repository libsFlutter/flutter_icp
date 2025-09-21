import 'package:json_annotation/json_annotation.dart';

part 'icp_account.g.dart';

/// Модель аккаунта ICP
@JsonSerializable()
class ICPAccount {
  final String principal;
  final String? subAccount;
  final BigInt balance;
  final Map<String, dynamic> metadata;

  const ICPAccount({
    required this.principal,
    this.subAccount,
    required this.balance,
    required this.metadata,
  });

  factory ICPAccount.fromJson(Map<String, dynamic> json) => ICPAccount(
        principal: json['principal'] as String,
        subAccount: json['sub_account'] as String?,
        balance: BigInt.parse(json['balance'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'principal': principal,
        'sub_account': subAccount,
        'balance': balance.toString(),
        'metadata': metadata,
      };
}

/// Модель транзакции ICP
@JsonSerializable()
class ICPTransaction {
  final String id;
  final String from;
  final String to;
  final BigInt amount;
  final DateTime timestamp;
  final String status;
  final String? memo;

  const ICPTransaction({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.memo,
  });

  factory ICPTransaction.fromJson(Map<String, dynamic> json) => ICPTransaction(
        id: json['id'] as String,
        from: json['from'] as String,
        to: json['to'] as String,
        amount: BigInt.parse(json['amount'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: json['status'] as String,
        memo: json['memo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'amount': amount.toString(),
        'timestamp': timestamp.toIso8601String(),
        'status': status,
        'memo': memo,
      };
}

/// Модель канистера ICP
@JsonSerializable()
class ICPCanisterInfo {
  final String id;
  final String name;
  final String status;
  final Map<String, dynamic> metadata;
  final List<String> controllers;

  const ICPCanisterInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.metadata,
    required this.controllers,
  });

  factory ICPCanisterInfo.fromJson(Map<String, dynamic> json) =>
      _$ICPCanisterInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ICPCanisterInfoToJson(this);
}
