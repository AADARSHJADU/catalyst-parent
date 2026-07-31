import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/messages_controller.dart';
import '../models/chat_user_model.dart';

class NewChatView extends GetView<MessagesController> {
  const NewChatView({super.key});

  static const _roles = [
    {'key': 'parent', 'label': 'Parent', 'icon': Icons.family_restroom},
    {'key': 'student', 'label': 'Student', 'icon': Icons.school_outlined},
    {
      'key': 'instructor',
      'label': 'Instructor',
      'icon': Icons.person_outlined
    },
    {'key': 'admin', 'label': 'Admin', 'icon': Icons.admin_panel_settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    // View mode: 'dm' or 'group'
    final RxString chatMode = 'dm'.obs;
    // Group state
    final RxList<ChatUserModel> selectedGroupMembers = <ChatUserModel>[].obs;
    final groupNameController = TextEditingController();

    // Load users for default role on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchUsers();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: Get.back,
        ),
        title: Obx(() => Text(
              chatMode.value == 'group' ? 'New Group Chat' : 'New Chat',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )),
        actions: [
          Obx(() => TextButton(
                onPressed: () {
                  chatMode.value = chatMode.value == 'dm' ? 'group' : 'dm';
                  selectedGroupMembers.clear();
                },
                child: Text(
                  chatMode.value == 'group' ? 'Direct Message' : 'New Group',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (chatMode.value == 'group') {
          return _GroupChatBuilder(
            controller: controller,
            roles: _roles,
            selectedMembers: selectedGroupMembers,
            groupNameController: groupNameController,
          );
        } else {
          return _DirectMessageBuilder(
            controller: controller,
            roles: _roles,
          );
        }
      }),
    );
  }
}

// ── Direct Message Builder ─────────────────────────────────────────────────────

class _DirectMessageBuilder extends StatelessWidget {
  const _DirectMessageBuilder({
    required this.controller,
    required this.roles,
  });
  final MessagesController controller;
  final List<Map<String, Object>> roles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoleFilter(controller: controller, roles: roles),
        Expanded(child: _UsersList(controller: controller)),
      ],
    );
  }
}

// ── Group Chat Builder ─────────────────────────────────────────────────────────

class _GroupChatBuilder extends StatelessWidget {
  const _GroupChatBuilder({
    required this.controller,
    required this.roles,
    required this.selectedMembers,
    required this.groupNameController,
  });
  final MessagesController controller;
  final List<Map<String, Object>> roles;
  final RxList<ChatUserModel> selectedMembers;
  final TextEditingController groupNameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Name input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextFormField(
            controller: groupNameController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Group name (e.g. Instructors Team)',
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        // Selected members chips
        Obx(() {
          if (selectedMembers.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: selectedMembers.map((u) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    label: Text(u.name.split(' ').first,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                    deleteIcon: const Icon(Icons.close,
                        size: 14, color: AppColors.primary),
                    onDeleted: () => selectedMembers.remove(u),
                  ),
                );
              }).toList(),
            ),
          );
        }),
        const SizedBox(height: 6),
        _RoleFilter(controller: controller, roles: roles),
        Expanded(
          child: _GroupUsersList(
            controller: controller,
            selectedMembers: selectedMembers,
          ),
        ),
        // Create Group button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedMembers.isEmpty
                      ? null
                      : () {
                          final name = groupNameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar('Error', 'Enter a group name',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          controller.createGroupConversation(
                            groupName: name,
                            members: selectedMembers.toList(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    selectedMembers.isEmpty
                        ? 'Select members first'
                        : 'Create Group (${selectedMembers.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}

// ── Role Filter ────────────────────────────────────────────────────────────────

class _RoleFilter extends StatelessWidget {
  const _RoleFilter({required this.controller, required this.roles});
  final MessagesController controller;
  final List<Map<String, Object>> roles;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: roles.map((r) {
              final isSelected = controller.selectedRole.value == r['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    controller.selectedRole.value = r['key'] as String;
                    controller.searchUsers(role: r['key'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          r['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          r['label'] as String,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Users List (DM mode) ───────────────────────────────────────────────────────

class _UsersList extends StatelessWidget {
  const _UsersList({required this.controller});
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearchingUsers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchedUsers.isEmpty) {
        return const Center(
          child: Text(
            'No users found',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.searchedUsers.length,
        itemBuilder: (ctx, i) => _UserTile(
          user: controller.searchedUsers[i],
          onTap: () => controller.startConversation(
            controller.searchedUsers[i],
          ),
        ),
      );
    });
  }
}

// ── Users List (Group multi-select mode) ──────────────────────────────────────

class _GroupUsersList extends StatelessWidget {
  const _GroupUsersList({
    required this.controller,
    required this.selectedMembers,
  });
  final MessagesController controller;
  final RxList<ChatUserModel> selectedMembers;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearchingUsers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchedUsers.isEmpty) {
        return const Center(
          child: Text(
            'No users found',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.searchedUsers.length,
        itemBuilder: (ctx, i) {
          final user = controller.searchedUsers[i];
          return Obx(() {
            final isSelected =
                selectedMembers.any((m) => m.id == user.id);
            return _UserTile(
              user: user,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  selectedMembers.removeWhere((m) => m.id == user.id);
                } else {
                  selectedMembers.add(user);
                }
              },
            );
          });
        },
      );
    });
  }
}

// ── User Tile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.onTap,
    this.isSelected = false,
  });
  final ChatUserModel user;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with initials
            Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.capitalizeFirst ?? user.role,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.chevron_right,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
