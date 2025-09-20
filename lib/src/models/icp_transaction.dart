import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icp_transaction.g.dart';

/// Represents an ICP transaction
@JsonSerializable()
class IcpTransaction extends Equatable {
  /// Transaction ID
  final String id;

  /// Transaction type
  final String type;

  /// Transaction amount
  final double amount;

  /// Transaction status
  final String status;

  /// Timestamp of the transaction
  final DateTime timestamp;

  /// Sender address
  final String? from;

  /// Recipient address
  final String? to;

  /// Transaction hash
  final String? hash;

  /// Additional transaction data
  final Map<String, dynamic>? data;

  const IcpTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.from,
    this.to,
    this.hash,
    this.data,
  });

  factory IcpTransaction.fromJson(Map<String, dynamic> json) =>
      _$IcpTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$IcpTransactionToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        status,
        timestamp,
        from,
        to,
        hash,
        data,
      ];
}
