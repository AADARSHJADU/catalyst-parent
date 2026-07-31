import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/group_info_controller.dart';

class GroupInfoView extends GetView<GroupInfoController> {
  const GroupInfoView({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Group Info',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group Header ──────────────────────────────────────────────────
          _GroupHeader(controller: controller),

          // ── Section: Members ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Members',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                      '${controller.members.length}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    )),
              ],
            ),
          ),

          // ── Add Member Row ─────────────────────────────────────────────────
          _AddMemberRow(controller: controller),

          // ── Members list ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.members.isEmpty) {
                return const Center(
                  child: Text(
                    'No members found',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 4),
                itemCount: controller.members.length,
                itemBuilder: (ctx, i) =>
                    _MemberTile(member: controller.members[i], controller: controller),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Group Header ───────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.controller});
  final GroupInfoController controller;

  @override
  Widget build(BuildContext context) {
    final conv = controller.conversation;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: AppColors.surface,
      child: Column(
        children: [
          // Group avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            conv.name ?? conv.subject,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                '${controller.members.length} members',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              )),
        ],
      ),
    );
  }
}

// ── Add Member Row ─────────────────────────────────────────────────────────────

class _AddMemberRow extends StatelessWidget {
  const _AddMemberRow({required this.controller});
  final GroupInfoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.addUserIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter User ID to add...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isWorking.value ? null : controller.addMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: controller.isWorking.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Member Tile ───────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.controller});
  final Map<String, dynamic> member;
  final GroupInfoController controller;

  @override
  Widget build(BuildContext context) {
    final name = controller.memberName(member);
    final initials = controller.memberInitials(member);
    final role = controller.memberRole(member);
    final isOwner = member['isOwner'] == true;

    return Dismissible(
      key: Key(member['id']?.toString() ?? name),
      direction:
          isOwner ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.remove_circle_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        controller.removeMember(member);
        return false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + role chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _RoleBadge(role: role),
                ],
              ),
            ),
            // Toggle admin button (not for owner)
            if (!isOwner)
              GestureDetector(
                onTap: () => controller.toggleAdminRole(member),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: member['isAdmin'] == true
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surface,
                    border: Border.all(
                      color: member['isAdmin'] == true
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member['isAdmin'] == true ? 'Remove Admin' : 'Make Admin',
                    style: TextStyle(
                      color: member['isAdmin'] == true
                          ? AppColors.primary
                          : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  Color get _color {
    switch (role) {
      case 'Owner':
        return const Color(0xFFFF9800);
      case 'Admin':
        return AppColors.primary;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
