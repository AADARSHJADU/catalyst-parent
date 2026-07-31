import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/conversation_model.dart';
import '../repositories/message_repository.dart';
import '../services/socket_service.dart';

/// Controller for the Group Info screen.
/// Manages member list and real-time group membership updates.
class GroupInfoController extends GetxController {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final _repo = MessageRepository.instance;
  final _socket = SocketService.instance;

  // ── Conversation ───────────────────────────────────────────────────────────
  late final ConversationModel conversation;

  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isWorking = false.obs; // Adding/removing/updating

  // ── Text controllers ──────────────────────────────────────────────────────
  final addUserIdController = TextEditingController();

  // ── Subscriptions ──────────────────────────────────────────────────────────
  StreamSubscription? _memberAddedSub;
  StreamSubscription? _memberRemovedSub;
  StreamSubscription? _memberRoleUpdatedSub;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as ConversationModel;
    _loadMembers();
    _listenSocketEvents();
  }

  @override
  void onClose() {
    _memberAddedSub?.cancel();
    _memberRemovedSub?.cancel();
    _memberRoleUpdatedSub?.cancel();
    addUserIdController.dispose();
    super.onClose();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  void _loadMembers() {
    // Populate from conversation.participants (already loaded)
    if (conversation.participants.isNotEmpty) {
      members.assignAll(conversation.participants);
    }
  }

  // ── Socket subscriptions ───────────────────────────────────────────────────

  void _listenSocketEvents() {
    _memberAddedSub = _socket.onGroupMemberAdded.listen((data) {
      if (data['conversationId']?.toString() == conversation.id) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          final alreadyExists =
              members.any((m) => m['id']?.toString() == user['id']?.toString());
          if (!alreadyExists) {
            members.add(user);
          }
        }
      }
    });

    _memberRemovedSub = _socket.onGroupMemberRemoved.listen((data) {
      if (data['conversationId']?.toString() == conversation.id) {
        final removedId = data['userId']?.toString();
        members.removeWhere((m) => m['id']?.toString() == removedId);
      }
    });

    _memberRoleUpdatedSub = _socket.onGroupMemberRoleUpdated.listen((data) {
      if (data['conversationId']?.toString() == conversation.id) {
        final updatedId = data['userId']?.toString();
        final isAdmin = data['isAdmin'] as bool? ?? false;
        final idx = members.indexWhere((m) => m['id']?.toString() == updatedId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(members[idx]);
          updated['isAdmin'] = isAdmin;
          members[idx] = updated;
        }
      }
    });
  }

  // ── Add member ─────────────────────────────────────────────────────────────

  Future<void> addMember() async {
    final userId = addUserIdController.text.trim();
    if (userId.isEmpty) {
      Get.snackbar('Error', 'Enter a User ID',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isWorking.value = true;
    try {
      await _repo.addMember(conversation.id, userId);
      addUserIdController.clear();
      Get.snackbar('Done', 'Member added successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Could not add member',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isWorking.value = false;
    }
  }

  // ── Remove member ──────────────────────────────────────────────────────────

  Future<void> removeMember(Map<String, dynamic> member) async {
    final userId = member['id']?.toString() ?? '';
    if (userId.isEmpty) return;
    isWorking.value = true;
    try {
      await _repo.removeMember(conversation.id, userId);
      members.removeWhere((m) => m['id']?.toString() == userId);
      Get.snackbar('Done', 'Member removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Could not remove member',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isWorking.value = false;
    }
  }

  // ── Toggle admin role ──────────────────────────────────────────────────────

  Future<void> toggleAdminRole(Map<String, dynamic> member) async {
    final userId = member['id']?.toString() ?? '';
    final currentIsAdmin = member['isAdmin'] as bool? ?? false;
    if (userId.isEmpty) return;
    isWorking.value = true;
    try {
      await _repo.updateMemberRole(conversation.id, userId, !currentIsAdmin);
      final idx = members.indexWhere((m) => m['id']?.toString() == userId);
      if (idx != -1) {
        final updated = Map<String, dynamic>.from(members[idx]);
        updated['isAdmin'] = !currentIsAdmin;
        members[idx] = updated;
      }
      Get.snackbar(
        'Done',
        !currentIsAdmin ? 'Member promoted to Admin' : 'Admin role removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not update role',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isWorking.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String memberName(Map<String, dynamic> m) {
    final fName = m['firstName']?.toString() ?? '';
    final lName = m['lastName']?.toString() ?? '';
    final full = '$fName $lName'.trim();
    if (full.isNotEmpty) return full;
    return m['name']?.toString() ?? 'User ${m['id']}';
  }

  String memberInitials(Map<String, dynamic> m) {
    final name = memberName(m);
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String memberRole(Map<String, dynamic> m) {
    if (m['isOwner'] == true) return 'Owner';
    if (m['isAdmin'] == true) return 'Admin';
    return 'Member';
  }
}
