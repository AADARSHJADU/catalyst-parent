import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../core/constants/api_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../notifications/models/in_app_notification_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Singleton Socket.IO service for real-time chat and notifications.
///
/// Usage:
///   SocketService.instance.connect();
///   SocketService.instance.onNewMessage.listen((msg) { ... });
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  Timer? _pingTimer;

  // ── Stream controllers ─────────────────────────────────────────────────────
  final _newMessageCtrl = StreamController<MessageModel>.broadcast();
  final _typingCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _typingStopCtrl = StreamController<String>.broadcast();
  final _messagesReadCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _newNotificationCtrl = StreamController<InAppNotificationModel>.broadcast();
  final _newConversationCtrl = StreamController<ConversationModel>.broadcast();
  final _groupMemberAddedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _groupMemberRemovedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _groupMemberRoleUpdatedCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageModel> get onNewMessage => _newMessageCtrl.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingCtrl.stream;
  Stream<String> get onUserStoppedTyping => _typingStopCtrl.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _messagesReadCtrl.stream;
  Stream<InAppNotificationModel> get onNewNotification => _newNotificationCtrl.stream;
  Stream<ConversationModel> get onNewConversation => _newConversationCtrl.stream;
  Stream<Map<String, dynamic>> get onGroupMemberAdded => _groupMemberAddedCtrl.stream;
  Stream<Map<String, dynamic>> get onGroupMemberRemoved => _groupMemberRemovedCtrl.stream;
  Stream<Map<String, dynamic>> get onGroupMemberRoleUpdated => _groupMemberRoleUpdatedCtrl.stream;

  // ── Connect ────────────────────────────────────────────────────────────────

  void connect() {
    if (isConnected) {
      debugPrint('[Socket] ℹ️ Socket is already connected.');
      return;
    }

    final token = StorageService.instance.getToken();
    final authHeader = (token != null && token.isNotEmpty)
        ? (token.startsWith('Bearer ') ? token : 'Bearer $token')
        : '';
    debugPrint('[Socket] 🔄 Initializing connection...');
    debugPrint('[Socket] 🔗 URL: ${ApiConstants.socketUrl}');
    debugPrint('[Socket] 🔑 Token present: ${token != null && token.isNotEmpty}');

    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setAuth({'token': authHeader})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] ✅ CONNECTED successfully to server');
      _startPingTimer();
    });

    _socket!.onDisconnect((reason) {
      debugPrint('[Socket] 🔌 DISCONNECTED: Reason = $reason');
      _stopPingTimer();
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] ❌ CONNECT ERROR: $err');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] ⚠️ SOCKET ERROR: $err');
    });

    _socket!.onReconnect((attempt) {
      debugPrint('[Socket] ♻️ RECONNECTED successfully on attempt #$attempt');
      _startPingTimer();
    });

    _socket!.onReconnectAttempt((attempt) {
      debugPrint('[Socket] 🔄 Reconnecting... Attempt #$attempt');
    });

    _socket!.onReconnectFailed((_) {
      debugPrint('[Socket] 🔴 Reconnection failed completely');
    });

    // ── Listen: pong ──────────────────────────────────────────────────────
    _socket!.on('pong', (_) {
      debugPrint('[Socket] 🏓 Pong received');
    });

    // ── Listen: new_message ──────────────────────────────────────────────
    _socket!.on('new_message', (data) {
      debugPrint('[Socket] 📨 Incoming Event: new_message -> $data');
      try {
        final Map<String, dynamic> rawMsg;
        if (data is Map && data['message'] != null) {
          rawMsg = Map<String, dynamic>.from(data['message'] as Map);
          // Inject conversationId from outer payload if missing in message
          if (rawMsg['conversationId'] == null &&
              rawMsg['conversation_id'] == null &&
              data['conversationId'] != null) {
            rawMsg['conversationId'] = data['conversationId'];
          }
        } else {
          rawMsg = data as Map<String, dynamic>;
        }
        final msg = MessageModel.fromJson(rawMsg);
        _newMessageCtrl.add(msg);
      } catch (e) {
        debugPrint('[Socket] ❌ Error parsing new_message: $e');
      }
    });

    // ── Listen: user_typing ──────────────────────────────────────────────
    _socket!.on('user_typing', (data) {
      debugPrint('[Socket] ✍️ Incoming Event: user_typing -> $data');
      _typingCtrl.add(data as Map<String, dynamic>);
    });

    // ── Listen: user_stopped_typing ──────────────────────────────────────
    _socket!.on('user_stopped_typing', (data) {
      debugPrint('[Socket] ⏹ Incoming Event: user_stopped_typing -> $data');
      final convId = (data as Map<String, dynamic>)['conversationId']
              ?.toString() ??
          '';
      _typingStopCtrl.add(convId);
    });

    // ── Listen: messages_read ────────────────────────────────────────────
    _socket!.on('messages_read', (data) {
      debugPrint('[Socket] ✅ Incoming Event: messages_read -> $data');
      _messagesReadCtrl.add(data as Map<String, dynamic>);
    });

    // ── Listen: new_notification ─────────────────────────────────────────
    _socket!.on('new_notification', (data) {
      debugPrint('[Socket] 🔔 Incoming Event: new_notification -> $data');
      try {
        final notif = InAppNotificationModel.fromJson(data as Map<String, dynamic>);
        _newNotificationCtrl.add(notif);
      } catch (e) {
        debugPrint('[Socket] ❌ Error parsing new_notification: $e');
      }
    });

    // ── Listen: new_conversation ─────────────────────────────────────────
    _socket!.on('new_conversation', (data) {
      debugPrint('[Socket] 💬 Incoming Event: new_conversation -> $data');
      try {
        final conv = ConversationModel.fromJson(data as Map<String, dynamic>);
        _newConversationCtrl.add(conv);
      } catch (e) {
        debugPrint('[Socket] ❌ Error parsing new_conversation: $e');
      }
    });

    // ── Listen: group_member_added ───────────────────────────────────────
    _socket!.on('group_member_added', (data) {
      debugPrint('[Socket] ➕ Incoming Event: group_member_added -> $data');
      _groupMemberAddedCtrl.add(data as Map<String, dynamic>);
    });

    // ── Listen: group_member_removed ─────────────────────────────────────
    _socket!.on('group_member_removed', (data) {
      debugPrint('[Socket] ➖ Incoming Event: group_member_removed -> $data');
      _groupMemberRemovedCtrl.add(data as Map<String, dynamic>);
    });

    // ── Listen: group_member_role_updated ────────────────────────────────
    _socket!.on('group_member_role_updated', (data) {
      debugPrint('[Socket] 🔑 Incoming Event: group_member_role_updated -> $data');
      _groupMemberRoleUpdatedCtrl.add(data as Map<String, dynamic>);
    });

    _socket!.connect();
  }

  // ── Room management ────────────────────────────────────────────────────────

  void joinConversation(String conversationId) {
    final payloadId = int.tryParse(conversationId) ?? conversationId;
    debugPrint('[Socket] 📤 Emitting join_conversation for room: $payloadId');
    _socket?.emit('join_conversation', {'conversationId': payloadId});
  }

  void leaveConversation(String conversationId) {
    final payloadId = int.tryParse(conversationId) ?? conversationId;
    debugPrint('[Socket] 📤 Emitting leave_conversation for room: $payloadId');
    _socket?.emit('leave_conversation', {'conversationId': payloadId});
  }

  // ── Typing indicators ──────────────────────────────────────────────────────

  void emitTypingStart(String conversationId) {
    final payloadId = int.tryParse(conversationId) ?? conversationId;
    debugPrint('[Socket] 📤 Emitting typing_start for conversation: $payloadId');
    _socket?.emit('typing_start', {'conversationId': payloadId});
  }

  void emitTypingStop(String conversationId) {
    final payloadId = int.tryParse(conversationId) ?? conversationId;
    debugPrint('[Socket] 📤 Emitting typing_stop for conversation: $payloadId');
    _socket?.emit('typing_stop', {'conversationId': payloadId});
  }

  // ── Ping ──────────────────────────────────────────────────────────────────

  void emitPing() {
    debugPrint('[Socket] 🏓 Emitting ping');
    _socket?.emit('ping');
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) => emitPing());
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────

  void disconnect() {
    _stopPingTimer();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    debugPrint('[Socket] Disposed');
  }

  void dispose() {
    _newMessageCtrl.close();
    _typingCtrl.close();
    _typingStopCtrl.close();
    _messagesReadCtrl.close();
    _newNotificationCtrl.close();
    _newConversationCtrl.close();
    _groupMemberAddedCtrl.close();
    _groupMemberRemovedCtrl.close();
    _groupMemberRoleUpdatedCtrl.close();
    disconnect();
  }
}
