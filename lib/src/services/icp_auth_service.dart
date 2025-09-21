import '../core/icp_exceptions.dart';
import 'enhanced_icp_service.dart';

/// Сервис аутентификации ICP
class ICPAuthService {
  final EnhancedICPService _icpService;
  String? _currentPrincipal;
  String? _privateKey;

  ICPAuthService(this._icpService);

  /// Аутентификация с ICP
  Future<bool> authenticate(String principal, String privateKey) async {
    try {
      // Здесь должна быть логика аутентификации с ICP
      // Это упрощенная версия для примера
      _currentPrincipal = principal;
      _privateKey = privateKey;

      // Проверяем что аккаунт существует
      await _icpService.getAccount(principal);
      return true;
    } catch (e) {
      _currentPrincipal = null;
      _privateKey = null;
      return false;
    }
  }

  /// Подпись транзакции
  Future<void> signTransaction(Map<String, dynamic> transaction) async {
    if (_privateKey == null) {
      throw ICPAuthException('Not authenticated');
    }

    // Здесь должна быть логика подписи транзакции
    // Это упрощенная версия для примера
    transaction['signature'] = 'signed_with_$_privateKey';
  }

  /// Текущий principal
  String? get currentPrincipal => _currentPrincipal;

  /// Проверка аутентификации
  bool get isAuthenticated => _currentPrincipal != null && _privateKey != null;

  /// Выход
  Future<void> logout() async {
    if (_currentPrincipal != null) {
      _icpService.disconnectFromAccount(_currentPrincipal!);
    }
    _currentPrincipal = null;
    _privateKey = null;
  }
}
