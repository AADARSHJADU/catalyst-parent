// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../models/conversation_model.dart';
import '../models/chat_user_model.dart';
import '../repositories/message_repository.dart';
import '../services/socket_service.dart';

class MessagesController extends GetxController {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final _repo = MessageRepository.instance;

  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showArchived = false.obs;
  final RxInt totalUnreadCount = 0.obs;

  // ── New chat state ─────────────────────────────────────────────────────────
  final RxList<ChatUserModel> searchedUsers = <ChatUserModel>[].obs;
  final RxBool isSearchingUsers = false.obs;
  final RxString selectedRole = 'parent'.obs;

  String? get currentUserId {
    final user = StorageService.instance.getUser();
    if (user != null && user['id'] != null) {
      return user['id'].toString();
    }
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
  StreamSubscription? _newConversationSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    SocketService.instance.connect();
    fetchConversations();
    fetchUnreadCount();
    _listenNewMessages();
    _listenNewConversations();
  }

  @override
  void onClose() {
    _newMessageSub?.cancel();
    _newConversationSub?.cancel();
    // Don't disconnect socket here — keep it alive across navigation
    super.onClose();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchConversations() async {
    print('fetchChatList');
    isLoading.value = true;
    try {
      final list =
          await _repo.fetchConversations(archived: showArchived.value);
      conversations.assignAll(list);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    final count = await _repo.fetchUnreadCount();
    totalUnreadCount.value = count;
  }

  void toggleArchived() {
    showArchived.value = !showArchived.value;
    fetchConversations();
  }

  // ── Real-time updates ──────────────────────────────────────────────────────

  void _listenNewMessages() {
    _newMessageSub = SocketService.instance.onNewMessage.listen((msg) {
      final idx = conversations.indexWhere(
        (c) => c.id.toString() == msg.conversationId.toString(),
      );
      if (idx != -1) {
        final existing = conversations[idx];
        final isFromMe = msg.senderId == currentUserId;
        final newUnread = isFromMe
            ? existing.unreadCount
            : existing.unreadCount + 1;

        final updated = ConversationModel(
          id: existing.id,
          senderId: existing.senderId,
          receiverId: existing.receiverId,
          subject: existing.subject,
          isGroup: existing.isGroup,
          name: existing.name,
          creatorId: existing.creatorId,
          isArchivedBySender: existing.isArchivedBySender,
          isArchivedByReceiver: existing.isArchivedByReceiver,
          latestMessage: msg.content,
          unreadCount: newUnread,
          participants: existing.participants,
          sender: existing.sender,
          receiver: existing.receiver,
          otherUser: existing.otherUser,
          isArchived: existing.isArchived,
          updatedAt: msg.createdAt,
        );
        conversations[idx] = updated;
        final conv = conversations.removeAt(idx);
        conversations.insert(0, conv);

        if (!isFromMe) {
          totalUnreadCount.value++;
        }
      }
    });
  }

  void _listenNewConversations() {
    _newConversationSub =
        SocketService.instance.onNewConversation.listen((conv) {
      // Only add if not already in list
      final alreadyExists = conversations.any((c) => c.id == conv.id);
      if (!alreadyExists) {
        conversations.insert(0, conv);
      }
    });
  }

  Future<void> archiveConversation(ConversationModel conv) async {
    try {
      final targetArchivedState = !conv.isArchived;
      await _repo.toggleArchive(conv.id, targetArchivedState);
      await fetchConversations();
      Get.snackbar(
        targetArchivedState ? 'Archived' : 'Unarchived',
        targetArchivedState
            ? 'Conversation archived'
            : 'Conversation restored',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ [MESSAGES CONTROLLER] Archive error: $e');
      Get.snackbar(
        'Error',
        'Could not update archive status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Search users for new chat ──────────────────────────────────────────────

  Future<void> searchUsers({String? role}) async {
    isSearchingUsers.value = true;
    try {
      final users = await _repo.searchUsers(role ?? selectedRole.value);
      searchedUsers.assignAll(users);
    } catch (_) {
    } finally {
      isSearchingUsers.value = false;
    }
  }

  // ── Start DM conversation ─────────────────────────────────────────────────

  Future<void> startConversation(ChatUserModel user) async {
    try {
      final conv = await _repo.startConversation(
        receiverId: user.id,
        subject: 'Chat with ${user.name}',
      );
      fetchConversations();
      Get.back(); // Close new chat screen
      Get.toNamed(AppRoutes.chat, arguments: conv);
    } catch (_) {}
  }

  // ── Create Group Conversation ─────────────────────────────────────────────

  Future<void> createGroupConversation({
    required String groupName,
    required List<ChatUserModel> members,
  }) async {
    final memberIds = members.map((u) => u.id).toList();
    print(' [CATALYST ADMIN] [createGroupConversation] Request Parameters:');
    print(' - groupName: $groupName');
    print(' - members: ${members.map((m) => '${m.name} (ID: ${m.id})').toList()}');
    print(' - memberIds: $memberIds');

    try {
      final conv = await _repo.createGroupConversation(
        name: groupName,
        memberIds: memberIds,
      );
      print(' [CATALYST ADMIN] [createGroupConversation] Success! Group Conversation created: ${conv.id}');
      fetchConversations();
      Get.back(); // Close new chat screen
      Get.toNamed(AppRoutes.chat, arguments: conv);
      Get.snackbar(
        'Success',
        'Group "$groupName" created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stack) {
      print(' [CATALYST ADMIN] [createGroupConversation] Error occurred:');
      print(' - Exception: $e');
      print(' - StackTrace: $stack');
      
      String errorMsg = e.toString();
      if (e is DioException) {
        try {
          if (e.response != null) {
            print(' - Response status: ${e.response!.statusCode}');
            print(' - Response data: ${e.response!.data}');
            errorMsg = 'Server response (${e.response!.statusCode}): ${e.response!.data}';
          }
        } catch (_) {}
      }

      Get.snackbar(
        'Error Creating Group',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  // ── Open conversation ──────────────────────────────────────────────────────

  void openConversation(ConversationModel conv) {
    // Reset unread count for that conversation locally
    final idx = conversations.indexWhere((c) => c.id == conv.id);
    if (idx != -1 && conversations[idx].unreadCount > 0) {
      totalUnreadCount.value =
          (totalUnreadCount.value - conversations[idx].unreadCount)
              .clamp(0, totalUnreadCount.value);
    }
    Get.toNamed(AppRoutes.chat, arguments: conv);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
