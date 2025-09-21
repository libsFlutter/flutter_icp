import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/icp_exceptions.dart';
import '../models/icp_account.dart';

/// Socket.IO менеджер для ICP
class ICPSocketManager {
  io.Socket? _socket;
  final String _serverUrl;

  ICPSocketManager({required String serverUrl}) : _serverUrl = serverUrl;

  /// Подключение к серверу
  Future<void> connect() async {
    try {
      _socket = io.io(
        _serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print('Connected to ICP server');
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from ICP server');
      });

      _socket!.onError((error) {
        print('Socket error: $error');
      });

      _socket!.connect();
    } catch (e) {
      throw ICPNetworkException('Failed to connect to socket: $e');
    }
  }

  /// Отключение от сервера
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Отправка события
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  /// Подписка на событие
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Отписка от события
  void off(String event) {
    _socket?.off(event);
  }

  /// Проверка подключения
  bool get isConnected => _socket?.connected ?? false;

  /// Подключение к аккаунту для получения обновлений
  void connectToAccount(String principal) {
    emit('join_account', {'principal': principal});
  }

  /// Отключение от аккаунта
  void disconnectFromAccount(String principal) {
    emit('leave_account', {'principal': principal});
  }

  /// Поток новых транзакций
  Stream<ICPTransaction> get transactionStream {
    final controller = StreamController<ICPTransaction>.broadcast();

    on('new_transaction', (data) {
      try {
        final transaction =
            ICPTransaction.fromJson(data as Map<String, dynamic>);
        controller.add(transaction);
      } catch (e) {
        controller
            .addError(ICPNetworkException('Error parsing transaction: $e'));
      }
    });

    return controller.stream;
  }

  /// Поток обновлений баланса
  Stream<Map<String, dynamic>> get balanceStream {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    on('balance_update', (data) {
      try {
        controller.add(data as Map<String, dynamic>);
      } catch (e) {
        controller
            .addError(ICPNetworkException('Error parsing balance update: $e'));
      }
    });

    return controller.stream;
  }

  /// Поток статуса канистеров
  Stream<Map<String, dynamic>> get canisterStatusStream {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    on('canister_status', (data) {
      try {
        controller.add(data as Map<String, dynamic>);
      } catch (e) {
        controller
            .addError(ICPNetworkException('Error parsing canister status: $e'));
      }
    });

    return controller.stream;
  }
}
