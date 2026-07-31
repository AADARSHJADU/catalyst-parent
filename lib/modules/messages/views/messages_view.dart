import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/messages_controller.dart';
import '../models/conversation_model.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _ArchiveToggle(controller: controller),
          Expanded(child: _ConversationsList(controller: controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.newChat),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          'New Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Obx(() {
        final unread = controller.totalUnreadCount.value;
        return Row(
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.textMuted),
          onPressed: controller.fetchConversations,
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

// ── Archive Toggle ─────────────────────────────────────────────────────────────

class _ArchiveToggle extends StatelessWidget {
  const _ArchiveToggle({required this.controller});
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(
        () => Row(
          children: [
            _TabChip(
              label: 'Active',
              selected: !controller.showArchived.value,
              onTap: () {
                if (controller.showArchived.value) controller.toggleArchived();
              },
            ),
            const SizedBox(width: 8),
            _TabChip(
              label: 'Archived',
              selected: controller.showArchived.value,
              onTap: () {
                if (!controller.showArchived.value) controller.toggleArchived();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Conversations List ─────────────────────────────────────────────────────────

class _ConversationsList extends StatelessWidget {
  const _ConversationsList({required this.controller});
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.conversations.isEmpty) {
        return _EmptyInbox(archived: controller.showArchived.value);
      }
      return RefreshIndicator(
        onRefresh: controller.fetchConversations,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.conversations.length,
          itemBuilder: (ctx, i) => _ConversationTile(
            conv: controller.conversations[i],
            controller: controller,
          ),
        ),
      );
    });
  }
}

// ── Conversation Tile ──────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conv,
    required this.controller,
  });
  final ConversationModel conv;
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    final name = conv.participantName(controller.currentUserId);
    final initials = _initials(name);
    final timeLabel = controller.timeLabel(conv.updatedAt);
    final hasUnread = conv.unreadCount > 0;

    return Dismissible(
      key: Key(conv.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: conv.isArchived
            ? const Color(0xFF4CAF50)
            : const Color(0xFF9E9E9E),
        child: Icon(
          conv.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        controller.archiveConversation(conv);
        return false;
      },
      child: InkWell(
        onTap: () => controller.openConversation(conv),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasUnread
                ? AppColors.primary.withValues(alpha: 0.04)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              _Avatar(
                initials: initials,
                avatarUrl: conv.participantAvatar(controller.currentUserId),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.latestMessage ?? conv.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                conv.unreadCount > 9
                                    ? '9+'
                                    : '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textMuted, size: 20),
                onSelected: (value) {
                  if (value == 'archive') {
                    controller.archiveConversation(conv);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          conv.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(conv.isArchived ? 'Unarchive' : 'Archive'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.avatarUrl});
  final String initials;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    String? fullUrl = avatarUrl;
    if (fullUrl != null && fullUrl.isNotEmpty && !fullUrl.startsWith('http')) {
      fullUrl = '${ApiConstants.baseUrl}$fullUrl';
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: (fullUrl != null && fullUrl.isNotEmpty)
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ── Empty inbox ────────────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.archived});
  final bool archived;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            archived ? Icons.archive_outlined : Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            archived ? 'No archived conversations' : 'No messages yet',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (!archived)
            const Text(
              'Tap + New Chat to start a conversation',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
