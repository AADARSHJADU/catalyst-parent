import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/document_model.dart';
import 'package:catalyst/modules/documents/controllers/documents_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: const Text('Documents'),
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value && controller.documents.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.documents.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.fetchDocuments,
          );
        }
        return _DocumentsContent(controller: controller);
      }),
    );
  }
}

// ── Error State ────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Content ──────────────────────────────────────────────────────────
class _DocumentsContent extends StatelessWidget {
  const _DocumentsContent({required this.controller});
  final DocumentsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchDocuments,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text('Documents', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Access important forms, waivers, and documents.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // ── Summary cards ──────────────────────────────────
          Obx(() => _StatsGrid(stats: controller.stats.value)),
          const SizedBox(height: 24),

          Text('All Documents', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Browse and download important documents and forms.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          // ── Search + filter ────────────────────────────────
          _SearchRow(controller: controller),
          const SizedBox(height: 12),

          // ── Document list ──────────────────────────────────
          Obx(() => _DocList(docs: controller.documents.toList())),
          const SizedBox(height: 12),

          // ── Pagination ───────────────────────────────────────
          Obx(() => _Pagination(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                totalItems: controller.totalItems.value,
                onPrev: controller.prevPage,
                onNext: controller.nextPage,
              )),
        ],
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final DocumentStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      // Lower ratio = taller cells. 1.35 was still ~3px too tight for the
      // icon row + label + "View X" row combo, so give it real headroom.
      childAspectRatio: 1.15,
      children: [
        _StatCard(
          icon: Icons.assignment_outlined,
          label: 'Waivers',
          count: stats.waivers,
          color: const Color(0xFF9C27B0),
          onTap: () => Get.find<DocumentsController>().setCategory('Waivers'),
        ),
        _StatCard(
          icon: Icons.policy_outlined,
          label: 'Policies',
          count: stats.policies,
          color: const Color(0xFF10B981),
          onTap: () => Get.find<DocumentsController>().setCategory('Policies'),
        ),
        _StatCard(
          icon: Icons.medical_information_outlined,
          label: 'Medical Forms',
          count: stats.medicalForms,
          color: const Color(0xFF3B82F6),
          onTap: () =>
              Get.find<DocumentsController>().setCategory('Medical Forms'),
        ),
        _StatCard(
          icon: Icons.download_outlined,
          label: 'Downloads',
          count: stats.downloads,
          color: AppColors.primary,
          onTap: () =>
              Get.find<DocumentsController>().setCategory('Downloads'),
        ),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
              // FittedBox protects against overflow if the count grows
              // large (e.g. 1,240) without needing a hardcoded height.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600, height: 1.1),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'View $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 14, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Search + Category Filter Row ─────────────────────────────────────────
class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller});
  final DocumentsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.setSearch,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search documents...',
              hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.surface,
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
                const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() => _CategoryChip(
          value: controller.selectedCategory.value,
          options: controller.categories,
          onChanged: controller.setCategory,
        )),
      ],
    );
  }
}

// ── Document List ─────────────────────────────────────────────────────────
class _DocList extends StatelessWidget {
  const _DocList({required this.docs});
  final List<ApiDocumentModel> docs;

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_off_outlined,
                  size: 40, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                'No documents found.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final doc in docs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DocCard(doc: doc),
          ),
      ],
    );
  }
}

// ── Document Card ─────────────────────────────────────────────────────────
class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc});
  final ApiDocumentModel doc;

  Color _catColor(String category) {
    switch (category) {
      case 'Waivers':
        return const Color(0xFF9C27B0);
      case 'Policies':
        return const Color(0xFF10B981);
      case 'Medical Forms':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.primary;
    }
  }

  IconData _catIcon(String category) {
    switch (category) {
      case 'Waivers':
        return Icons.assignment_outlined;
      case 'Policies':
        return Icons.policy_outlined;
      case 'Medical Forms':
        return Icons.medical_information_outlined;
      default:
        return Icons.download_outlined;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return '';
    }
  }

  Future<void> _download() async {
    final url = doc.fileUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar('Error', 'Download URL not available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open document.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(doc.category);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  doc.fileTypeUpper,
                  style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: Theme.of(context).textTheme.titleSmall),
                    if (doc.description != null &&
                        doc.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        doc.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              // Download button moved beside the title on wide rows so the
              // card doesn't feel bottom-heavy; still tappable and compact.
              IconButton(
                onPressed: _download,
                icon: const Icon(Icons.download_outlined,
                    size: 20, color: AppColors.primary),
                tooltip: 'Download',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_catIcon(doc.category), size: 11, color: color),
                    const SizedBox(width: 4),
                    Text(
                      doc.category,
                      style: TextStyle(
                          color: color, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (doc.fileSizeFormatted.isNotEmpty)
                _chip(Icons.insert_drive_file_outlined,
                    '${doc.fileTypeUpper} • ${doc.fileSizeFormatted}'),
              if (doc.updatedAt != null)
                _chip(Icons.calendar_today_outlined, _formatDate(doc.updatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Category Filter Chip ──────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Filter by Category',
                      style:
                      TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ...options.map((opt) => ListTile(
                dense: true,
                title: Text(
                  opt,
                  style: TextStyle(
                    color: opt == value
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                trailing: opt == value
                    ? const Icon(Icons.check,
                    color: AppColors.primary, size: 16)
                    : null,
                onTap: () {
                  onChanged(opt);
                  Get.back();
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                value,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Pagination ─────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPrev,
    required this.onNext,
  });
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final start = (currentPage - 1) * 10 + 1;
    final end = (currentPage * 10).clamp(0, totalItems);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing $start to $end of $totalItems',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: currentPage > 1 ? onPrev : null,
          icon: Icon(
            Icons.chevron_left,
            color: currentPage > 1 ? AppColors.textPrimary : AppColors.textMuted,
          ),
          iconSize: 20,
        ),
        Text(
          '$currentPage / $totalPages',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        IconButton(
          onPressed: currentPage < totalPages ? onNext : null,
          icon: Icon(
            Icons.chevron_right,
            color: currentPage < totalPages ? AppColors.textPrimary : AppColors.textMuted,
          ),
          iconSize: 20,
        ),
      ],
    );
  }
}