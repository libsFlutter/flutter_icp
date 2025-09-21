import 'package:json_annotation/json_annotation.dart';

part 'icp_account.g.dart';

/// Модель аккаунта ICP
@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory ICPAccount.fromJson(Map<String, dynamic> json) =>
      _$ICPAccountFromJson(json);

  Map<String, dynamic> toJson() => _$ICPAccountToJson(this);
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

  factory ICPTransaction.fromJson(Map<String, dynamic> json) =>
      _$ICPTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$ICPTransactionToJson(this);
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
