import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Model (local copy) ────────────────────────────────────────────────────────
class _Result {
  const _Result({
    required this.event,
    required this.dates,
    required this.category,
    required this.result,
    required this.score,
    required this.feedback,
    required this.place,
  });
  final String event;
  final String dates;
  final String category;
  final String result;
  final String score;
  final String feedback;
  final int place;
}

// ── Mock data ─────────────────────────────────────────────────────────────────
const _kResults = [
  _Result(
    event: 'Spring Dance Classic',
    dates: 'May 3 – May 4, 2025',
    category: 'Jazz – Advanced',
    result: '1st Place',
    score: '94.5 / 100',
    feedback:
        'Excellent technique and great stage presence! The group showed outstanding energy from start to finish. Clean lines throughout with exceptional synchronicity. A truly memorable performance that captivated the audience.',
    place: 1,
  ),
  _Result(
    event: 'Showtime Nationals',
    dates: 'Apr 10 – Apr 13, 2025',
    category: 'Contemporary – Intermediate',
    result: '2nd Place',
    score: '91.0 / 100',
    feedback:
        'Strong performance overall with beautiful emotional expression. Work on the transitions between sections — they felt slightly rushed at times. The choreography showcased each dancer\'s individual strength effectively.',
    place: 2,
  ),
  _Result(
    event: 'Revolution Dance Challenge',
    dates: 'Mar 22 – Mar 23, 2025',
    category: 'Hip Hop – Beginner',
    result: '3rd Place',
    score: '88.0 / 100',
    feedback:
        'Great energy and impressive improvement since last season! The group\u2019s enthusiasm was infectious. Focus on sharpening your isolations and hitting counts precisely to elevate to the next level.',
    place: 3,
  ),
  _Result(
    event: 'Winter Wonderland Showcase',
    dates: 'Dec 14 – Dec 15, 2024',
    category: 'Ballet – Intermediate',
    result: '2nd Place',
    score: '90.0 / 100',
    feedback:
        'Beautiful lines and graceful movement. Posture was excellent throughout. Continue refining the port de bras in the adagio section and this group will be competing at the top tier next year.',
    place: 2,
  ),
];

// ── Helper: trophy colour ─────────────────────────────────────────────────────
Color _trophyColor(int place) {
  switch (place) {
    case 1:
      return const Color(0xFFF59E0B);
    case 2:
      return const Color(0xFF94A3B8);
    case 3:
      return const Color(0xFFCD7C4B);
    default:
      return AppColors.primary;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AllResultsView
// ══════════════════════════════════════════════════════════════════════════════
class AllResultsView extends StatefulWidget {
  const AllResultsView({super.key});

  @override
  State<AllResultsView> createState() => _AllResultsViewState();
}

class _AllResultsViewState extends State<AllResultsView> {
  String _query = '';

  List<_Result> get _filtered => _kResults
      .where((r) =>
          r.event.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        title: const Text('All Results & Feedback',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Filter by event name…',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          // Results list
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('No results found.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ResultCard(result: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final _Result result;

  @override
  Widget build(BuildContext context) {
    final color = _trophyColor(result.place);
    return AppCard(
      onTap: () => _showDetail(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trophy icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.emoji_events, size: 24, color: color),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.event,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(result.dates,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(result.category,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                // Feedback snippet
                Text(
                  result.feedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Result + score column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 12, color: color),
                  const SizedBox(width: 3),
                  Text(result.result,
                      style:
                          TextStyle(color: color, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 4),
              Text(result.score,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Trophy + event
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _trophyColor(result.place)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.emoji_events,
                        size: 28, color: _trophyColor(result.place)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.event,
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      Text(result.dates,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            _DetailLine(label: 'Category', value: result.category),
            _DetailLine(label: 'Result', value: result.result),
            _DetailLine(label: 'Score', value: result.score),
            const SizedBox(height: 14),
            Text('Instructor Feedback',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(result.feedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary, height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
