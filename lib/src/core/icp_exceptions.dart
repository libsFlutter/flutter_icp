import 'package:flutter_nft/flutter_nft.dart';

/// Base exception for all ICP operations
abstract class ICPException extends NFTException {
  const ICPException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP canister is not available
class ICPCanisterNotAvailableException extends ICPException {
  const ICPCanisterNotAvailableException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP principal is invalid
class ICPPrincipalInvalidException extends ICPException {
  const ICPPrincipalInvalidException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP account is invalid
class ICPAccountInvalidException extends ICPException {
  const ICPAccountInvalidException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP transaction fails
class ICPTransactionException extends ICPException {
  const ICPTransactionException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP balance is insufficient
class ICPInsufficientBalanceException extends ICPException {
  const ICPInsufficientBalanceException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP network is unreachable
class ICPNetworkException extends ICPException {
  const ICPNetworkException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP call fails
class ICPCallException extends ICPException {
  const ICPCallException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP authentication fails
class ICPAuthenticationException extends ICPException {
  const ICPAuthenticationException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP authorization fails
class ICPAuthorizationException extends ICPException {
  const ICPAuthorizationException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP query fails
class ICPQueryException extends ICPException {
  const ICPQueryException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP update call fails
class ICPUpdateException extends ICPException {
  const ICPUpdateException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP configuration is invalid
class ICPConfigurationException extends ICPException {
  const ICPConfigurationException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP service is not initialized
class ICPServiceNotInitializedException extends ICPException {
  const ICPServiceNotInitializedException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP service is already initialized
class ICPServiceAlreadyInitializedException extends ICPException {
  const ICPServiceAlreadyInitializedException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP timeout occurs
class ICPTimeoutException extends ICPException {
  const ICPTimeoutException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP rate limit is exceeded
class ICPRateLimitException extends ICPException {
  const ICPRateLimitException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP quota is exceeded
class ICPQuotaExceededException extends ICPException {
  const ICPQuotaExceededException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP canister is full
class ICPCanisterFullException extends ICPException {
  const ICPCanisterFullException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP cycles are insufficient
class ICPInsufficientCyclesException extends ICPException {
  const ICPInsufficientCyclesException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP memory is insufficient
class ICPInsufficientMemoryException extends ICPException {
  const ICPInsufficientMemoryException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP storage is insufficient
class ICPInsufficientStorageException extends ICPException {
  const ICPInsufficientStorageException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when ICP computation is insufficient
class ICPInsufficientComputationException extends ICPException {
  const ICPInsufficientComputationException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Exception thrown when wallet is not connected
class WalletNotConnectedException extends ICPException {
  const WalletNotConnectedException(String message,
      {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
