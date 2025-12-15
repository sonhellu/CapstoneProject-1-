import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_config.dart';
import 'auth_service.dart';

/// Socket Service - Quản lý WebSocket connection cho real-time chat
class SocketService {
  static IO.Socket? _socket;
  static bool _isConnecting = false;
  static bool _isConnected = false;

  /// Get singleton socket instance
  static IO.Socket? get socket => _socket;

  /// Check if socket is connected
  static bool get isConnected => _isConnected && _socket?.connected == true;

  /// Initialize and connect socket
  static Future<void> connect() async {
    if (_socket != null && _isConnected) {
      return; // Already connected
    }

    if (_isConnecting) {
      return; // Already connecting
    }

    try {
      _isConnecting = true;

      // Get auth token
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('SocketService: No auth token available');
        _isConnecting = false;
        return;
      }

      // Disconnect existing socket if any
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      // Create socket connection
      final socketUrl = ApiConfig.baseUrl;
      print('SocketService: Connecting to $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['polling', 'websocket']) // Try polling first (more reliable on Render)
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(3) // Reduce attempts for faster fallback
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(5000)
            .setTimeout(30000) // Increased timeout for Render
            .setAuth({'token': token}) // Send token in auth parameter
            .build(),
      );

      // Setup event handlers
      _setupEventHandlers();

      // Connect with auth
      _socket!.connect();

      // Wait for connection with timeout
      int attempts = 0;
      while (attempts < 10 && !_isConnected) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
        if (_socket?.connected == true) {
          _isConnected = true;
          break;
        }
      }
      
      _isConnecting = false;
      
      if (!_isConnected) {
        print('SocketService: Failed to connect after timeout');
        // Cleanup failed connection
        _socket?.disconnect();
        _socket?.dispose();
        _socket = null;
      }
    } catch (e) {
      print('SocketService: Connection error: $e');
      _isConnecting = false;
      _isConnected = false;
    }
  }

  /// Setup socket event handlers
  static void _setupEventHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('SocketService: Connected');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print('SocketService: Disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('SocketService: Connection error: $error');
      _isConnected = false;
      // Don't throw - let the app fallback to REST API
    });

    _socket!.onError((error) {
      print('SocketService: Error: $error');
      _isConnected = false;
      // Don't throw - let the app fallback to REST API
    });

    _socket!.onDisconnect((reason) {
      print('SocketService: Disconnected: $reason');
      _isConnected = false;
    });

    // Handle connected event from server
    _socket!.on('connected', (data) {
      print('SocketService: Server confirmed connection: $data');
      _isConnected = true;
    });
  }

  /// Join a conversation room
  static void joinConversation(int conversationId) {
    if (!isConnected || _socket == null) {
      print('SocketService: Cannot join - not connected');
      return;
    }

    print('SocketService: Joining conversation $conversationId');
    _socket!.emit('join_conversation', {'conversation_id': conversationId});
  }

  /// Leave a conversation room
  static void leaveConversation(int conversationId) {
    if (!isConnected || _socket == null) {
      return;
    }

    print('SocketService: Leaving conversation $conversationId');
    _socket!.emit('leave_conversation', {'conversation_id': conversationId});
  }

  /// Send a message via socket
  static void sendMessage({
    required int conversationId,
    required String content,
  }) {
    if (!isConnected || _socket == null) {
      print('SocketService: Cannot send - not connected');
      return;
    }

    print('SocketService: Sending message to conversation $conversationId');
    _socket!.emit('send_message', {
      'conversation_id': conversationId,
      'content': content,
    });
  }

  /// Listen to new messages
  static void onNewMessage(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;
    _socket!.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// Listen to message sent confirmation
  static void onMessageSent(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;
    _socket!.on('message_sent', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// Listen to errors
  static void onError(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;
    _socket!.on('error', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// Remove all listeners for a specific event
  static void off(String event) {
    _socket?.off(event);
  }

  /// Remove all listeners
  static void removeAllListeners() {
    _socket?.clearListeners();
  }

  /// Disconnect socket
  static void disconnect() {
    if (_socket != null) {
      print('SocketService: Disconnecting');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Reconnect socket
  static Future<void> reconnect() async {
    disconnect();
    await connect();
  }
}

