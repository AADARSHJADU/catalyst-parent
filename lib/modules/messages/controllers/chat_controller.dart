import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';
import '../services/socket_service.dart';

class ChatController extends GetxController {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final _repo = MessageRepository.instance;
  final _socket = SocketService.instance;

  // ── Conversation ───────────────────────────────────────────────────────────
  late final ConversationModel conversation;

  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isTyping = false.obs; // Someone else is typing
  final RxBool isArchived = false.obs;

  // ── Text input ─────────────────────────────────────────────────────────────
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // ── Attachment ─────────────────────────────────────────────────────────────
  final RxString attachmentPath = ''.obs;
  final RxString attachmentName = ''.obs;

  // ── Typing timer ───────────────────────────────────────────────────────────
  Timer? _typingTimer;

  // ── Current user ──────────────────────────────────────────────────────────
  String? get currentUserId {
    // Try from stored user data first
    final user = StorageService.instance.getUser();
    if (user != null && user['id'] != null) {
      return user['id'].toString();
    }
    // Fallback: decode user id from JWT token
    final token = StorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final map = jsonDecode(decoded) as Map<String, dynamic>;
          return map['id']?.toString();
        }
      } catch (_) {}
    }
    return null;
  }

  // ── Subscriptions ──────────────────────────────────────────────────────────
  StreamSubscription? _newMessageSub;
  StreamSubscription? _typingStartSub;
  StreamSubscription? _typingStopSub;
  StreamSubscription? _readSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationModel;
    isArchived.value = conversation.isArchived;
    _fetchMessages();
    _joinRoom();
    _listenSocket();
  }

  @override
  void onClose() {
    _leaveRoom();
    _typingTimer?.cancel();
    _newMessageSub?.cancel();
    _typingStartSub?.cancel();
    _typingStopSub?.cancel();
    _readSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> _fetchMessages() async {
    isLoading.value = true;
    try {
      final list = await _repo.fetchMessages(
        conversation.id,
        limit: 50,
        offset: 0,
      );
      // Sort chronologically (oldest message first -> newest message last)
      list.sort((a, b) {
        final cmp = a.createdAt.compareTo(b.createdAt);
        if (cmp != 0) return cmp;
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idA.compareTo(idB);
      });

      messages.assignAll(list);
      isLoading.value = false;
      _scrollToBottom(animate: false);
      // Mark as read
      await _repo.markAsRead(conversation.id);
    } catch (_) {
      isLoading.value = false;
    }
  }

  // ── Socket room ────────────────────────────────────────────────────────────

  void _joinRoom() {
    _socket.joinConversation(conversation.id);
  }

  void _leaveRoom() {
    _socket.leaveConversation(conversation.id);
  }

  void _listenSocket() {
    // New message
    _newMessageSub = _socket.onNewMessage.listen((msg) {
      // Compare as strings to avoid int vs string mismatch
      if (msg.conversationId.toString() == conversation.id.toString()) {
        // Prevent duplicate message rendering
        final isDuplicate = messages.any(
          (m) =>
              m.id == msg.id ||
              (m.content == msg.content &&
                  m.senderId == msg.senderId &&
                  m.createdAt.difference(msg.createdAt).inSeconds.abs() < 5),
        );
        if (!isDuplicate) {
          messages.add(msg);
          _scrollToBottom();
          _repo.markAsRead(conversation.id);
        }
      }
    });

    // Typing start
    _typingStartSub = _socket.onUserTyping.listen((data) {
      if (data['conversationId']?.toString() == conversation.id.toString()) {
        isTyping.value = true;
        _scrollToBottom();
      }
    });

    // Typing stop
    _typingStopSub = _socket.onUserStoppedTyping.listen((convId) {
      if (convId.toString() == conversation.id.toString()) {
        isTyping.value = false;
      }
    });

    // Read receipts
    _readSub = _socket.onMessagesRead.listen((data) {
      if (data['conversationId']?.toString() == conversation.id.toString()) {
        for (int i = 0; i < messages.length; i++) {
          if (!messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true);
          }
        }
        messages.refresh();
      }
    });
  }

  // ── Typing ─────────────────────────────────────────────────────────────────

  void onInputChanged(String value) {
    if (value.isEmpty) return;
    _socket.emitTypingStart(conversation.id);
    _typingTimer?.cancel();
    // Auto-stop after 1.5 seconds of no typing
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      _socket.emitTypingStop(conversation.id);
    });
  }

  // ── Send ───────────────────────────────────────────────────────────────────

  Future<void> sendMessage() async {
    if (isSending.value) return;

    final text = messageController.text.trim();
    final filePath = attachmentPath.value;

    if (text.isEmpty && filePath.isEmpty) return;

    isSending.value = true;
    _typingTimer?.cancel();
    _socket.emitTypingStop(conversation.id);

    try {
      final msg = await _repo.sendMessage(
        conversation.id,
        content: text,
        filePath: filePath.isNotEmpty ? filePath : null,
        fileName: attachmentName.value.isNotEmpty ? attachmentName.value : null,
      );
      messageController.clear();
      attachmentPath.value = '';
      attachmentName.value = '';

      // Add message if not already added by socket stream
      final isAlreadyInList = messages.any((m) => m.id == msg.id);
      if (!isAlreadyInList) {
        messages.add(msg);
        _scrollToBottom();
      }
    } catch (_) {
    } finally {
      isSending.value = false;
    }
  }

  // ── Attachment ─────────────────────────────────────────────────────────────

  void setAttachment(String path, String name) {
    attachmentPath.value = path;
    attachmentName.value = name;
  }

  void clearAttachment() {
    attachmentPath.value = '';
    attachmentName.value = '';
  }

  // ── Scroll ─────────────────────────────────────────────────────────────────

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        if (animate) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(
            scrollController.position.maxScrollExtent,
          );
        }
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool isSentByMe(MessageModel msg) => msg.senderId == currentUserId;

  String get conversationTitle {
    return conversation.participantName(currentUserId);
  }

  Future<void> toggleArchive() async {
    final nextState = !isArchived.value;
    try {
      await _repo.toggleArchive(conversation.id, nextState);
      isArchived.value = nextState;
      Get.snackbar(
        nextState ? 'Archived' : 'Unarchived',
        nextState ? 'Conversation archived' : 'Conversation restored',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [CHAT CONTROLLER] Archive error: $e');
      Get.snackbar(
        'Error',
        'Could not update archive status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
