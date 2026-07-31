/*
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../messages/controllers/chat_controller.dart';

const _chatPurple = Color(0xFF7C3AED);

// ══════════════════════════════════════════════════════════════════════════════
// Root Tab — Studio Messages | Instructor Chat
// ══════════════════════════════════════════════════════════════════════════════
class ChatTab extends GetView<ChatController> {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                      style: Theme.of(context).textTheme.displayMedium,
                      ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay connected with your studio and instructors.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Tab pills
                  Obx(() => Row(children: [
                        _TabPill(
                          label: 'Studio Messages',
                          icon: Icons.business_outlined,
                          selected: controller.chatTab.value == 0,
                          onTap: () => controller.chatTab.value = 0,
                        ),
                        const SizedBox(width: 8),
                        _TabPill(
                          label: 'Instructor Chat',
                          icon: Icons.chat_bubble_outline,
                          selected: controller.chatTab.value == 1,
                          onTap: () => controller.chatTab.value = 1,
                        ),
                      ])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),

            // Body
            Expanded(
              child: Obx(() => controller.chatTab.value == 0
                  ? const _StudioPane()
                  : const _InstructorListPane()),
            ),

            // Footer
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Messages are only visible to authorized users and instructors.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab pill ──────────────────────────────────────────────────────────────────
class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? _chatPurple.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _chatPurple : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color:
                    selected ? _chatPurple : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? _chatPurple
                      : AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STUDIO MESSAGES PANE
// ══════════════════════════════════════════════════════════════════════════════
class _StudioPane extends GetView<ChatController> {
  const _StudioPane();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search + compose
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: _searchDecoration('Search messages...'),
                ),
              ),
              const SizedBox(width: 10),
              _IconBox(
                icon: Icons.edit_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Studio Messages',
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        Expanded(
          child: Obx(() {
            final msgs = controller.filteredStudioMessages;
            if (msgs.isEmpty) {
              return _Empty(message: 'No messages found');
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: msgs.length + 1,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (ctx, i) {
                if (i == msgs.length) {
                  return _TextRow(
                    label: 'View All Messages',
                    onTap: () {},
                  );
                }
                return _StudioTile(message: msgs[i]);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _StudioTile extends StatelessWidget {
  const _StudioTile({required this.message});
  final StudioMessage message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _chatPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business_outlined,
                  size: 22, color: _chatPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: message.isUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(message.date,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: message.isUnread
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                        ),
                      ),
                      if (message.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: _chatPurple,
                              shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            _DragHandle(),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _chatPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_outlined,
                      size: 22, color: _chatPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium),
                      Text(
                          'Catalyst Dance Studio · ${message.date}',
                          style:
                              Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Text(message.preview,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.7)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INSTRUCTOR LIST PANE  (WhatsApp-style conversation list)
// ══════════════════════════════════════════════════════════════════════════════
class _InstructorListPane extends GetView<ChatController> {
  const _InstructorListPane();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => controller.instructorSearchQuery.value = v,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: _searchDecoration('Search instructors...'),
          ),
        ),
        Expanded(
          child: Obx(() {
            final convs = controller.filteredConversations;
            if (convs.isEmpty) {
              return _Empty(message: 'No conversations found');
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: convs.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, color: AppColors.border, indent: 76),
              itemBuilder: (ctx, i) => _ConversationTile(
                conv: convs[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ChatDetailScreen(conv: convs[i]),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Conversation tile (like WhatsApp chat list row) ───────────────────────────
class _ConversationTile extends StatelessWidget {
  const _ConversationTile(
      {required this.conv, required this.onTap});
  final InstructorConversation conv;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastMsg = conv.messages.isNotEmpty
        ? conv.messages.last
        : null;
    final unread = conv.unreadCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      _chatPurple.withValues(alpha: 0.2),
                  child: Text(
                    conv.instructorName
                        .split(' ')
                        .map((p) => p[0])
                        .join(),
                    style: const TextStyle(
                        color: _chatPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.background,
                            width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.instructorName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: unread > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                      ),
                      // Time of last message
                      if (lastMsg != null)
                        Text(
                          _shortTime(lastMsg.time),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: unread > 0
                                    ? _chatPurple
                                    : AppColors.textMuted,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg != null
                              ? (lastMsg.isMe
                                  ? 'You: ${lastMsg.text}'
                                  : lastMsg.text)
                              : conv.specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: unread > 0
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                        ),
                      ),
                      // Unread badge
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: _chatPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortTime(String time) {
    // e.g. "May 19, 2025 4:15 PM" → "4:15 PM"
    final parts = time.split(' ');
    if (parts.length >= 5) return '${parts[3]} ${parts[4]}';
    return parts.last;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHAT DETAIL SCREEN  (pushed via Navigator — WhatsApp style)
// ══════════════════════════════════════════════════════════════════════════════
class _ChatDetailScreen extends StatefulWidget {
  const _ChatDetailScreen({required this.conv});
  final InstructorConversation conv;

  @override
  State<_ChatDetailScreen> createState() =>
      _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  late InstructorConversation _conv;
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _inputText = ''.obs;

  @override
  void initState() {
    super.initState();
    _conv = widget.conv;
    // Mark as read — deferred to after first frame to avoid
    // setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<ChatController>();
      final idx =
          ctrl.conversations.indexWhere((c) => c.id == _conv.id);
      if (idx != -1 && _conv.unreadCount > 0) {
        final updated = InstructorConversation(
          id: _conv.id,
          instructorName: _conv.instructorName,
          specialty: _conv.specialty,
          isOnline: _conv.isOnline,
          unreadCount: 0,
          messages: _conv.messages,
        );
        ctrl.conversations[idx] = updated;
        setState(() => _conv = updated);
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final ctrl = Get.find<ChatController>();
    final now = DateTime.now();
    final timeStr = _fmt(now);

    final newMsg = ChatMessage(
      id: '${_conv.messages.length + 1}',
      text: text,
      time: timeStr,
      isMe: true,
    );

    final updated = InstructorConversation(
      id: _conv.id,
      instructorName: _conv.instructorName,
      specialty: _conv.specialty,
      isOnline: _conv.isOnline,
      unreadCount: 0,
      messages: [..._conv.messages, newMsg],
    );

    final idx = ctrl.conversations
        .indexWhere((c) => c.id == _conv.id);
    if (idx != -1) ctrl.conversations[idx] = updated;

    setState(() => _conv = updated);
    _textCtrl.clear();
    _inputText.value = '';
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = d.hour > 12
        ? d.hour - 12
        : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} $h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0.5,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      _chatPurple.withValues(alpha: 0.2),
                  child: Text(
                    _conv.instructorName
                        .split(' ')
                        .map((p) => p[0])
                        .join(),
                    style: const TextStyle(
                        color: _chatPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (_conv.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.card, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_conv.instructorName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium),
                  Row(
                    children: [
                      if (_conv.isOnline) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text('Online',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppColors.success)),
                      ] else
                        Text(_conv.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textSecondary),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _conv.messages.length,
              itemBuilder: (ctx, i) {
                final msg = _conv.messages[i];
                // Date separator
                final showDate = i == 0 ||
                    _dateOf(_conv.messages[i - 1].time) !=
                        _dateOf(msg.time);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showDate)
                      _DateSep(label: _dateOf(msg.time)),
                    _Bubble(message: msg),
                  ],
                );
              },
            ),
          ),

          // Input bar
          _InputBar(
            controller: _textCtrl,
            inputText: _inputText,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  String _dateOf(String time) {
    final p = time.split(' ');
    return p.length >= 3
        ? '${p[0]} ${p[1]} ${p[2]}'
        : time;
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.textPrimary),
            title: const Text('View Profile',
                style:
                    TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Profile', 'Coming soon',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(
                Icons.notifications_off_outlined,
                color: AppColors.textPrimary),
            title: const Text('Mute Notifications',
                style:
                    TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Muted', 'Notifications muted',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: AppColors.error),
            title: const Text('Clear Chat',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Date separator ─────────────────────────────────────────────────────────────
class _DateSep extends StatelessWidget {
  const _DateSep({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 6,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Instructor name (only first message in group)
          if (!isMe && message.senderName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(message.senderName,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: _chatPurple)),
            ),

          // Bubble
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: isMe ? _chatPurple : AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: AppColors.border, width: 0.5),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color:
                    isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          // Time
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(
              _shortTime(message.time),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _shortTime(String t) {
    final p = t.split(' ');
    if (p.length >= 5) return '${p[3]} ${p[4]}';
    return t;
  }
}

// ── Input bar ──────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.inputText,
    required this.onSend,
  });
  final TextEditingController controller;
  final RxString inputText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (v) => inputText.value = v,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),

                prefixIcon: IconButton(
                  onPressed: () {
                    // attachment action
                  },
                  icon: const Icon(
                    Icons.attach_file_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),

                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: _chatPurple,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Obx(() {
              final hasText = inputText.value.trim().isNotEmpty;
              return GestureDetector(
                onTap: hasText ? onSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:
                        hasText ? _chatPurple : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasText
                          ? _chatPurple
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: hasText
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════════════════════
InputDecoration _searchDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle:
        const TextStyle(color: AppColors.textMuted, fontSize: 13),
    prefixIcon: const Icon(Icons.search,
        color: AppColors.textSecondary, size: 18),
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          const BorderSide(color: _chatPurple, width: 1.5),
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon,
            size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
*/
