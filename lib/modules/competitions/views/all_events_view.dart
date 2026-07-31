import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Models (local copy) ───────────────────────────────────────────────────────
class _Event {
  const _Event({
    required this.title,
    required this.date,
    required this.location,
    required this.tag,
    required this.tagColor,
    this.description =
        'Join us for an exciting dance event showcasing talented performers from across the region. This event features multiple categories and age divisions.',
  });
  final String title;
  final String date;
  final String location;
  final String tag;
  final Color tagColor;
  final String description;
}

// ── Mock data ─────────────────────────────────────────────────────────────────
const _kEvents = [
  _Event(
    title: 'Summer Showcase 2025',
    date: 'Jun 21, 2025 · 6:00 PM',
    location: 'Catalyst Dance Theater',
    tag: 'Featured',
    tagColor: Color(0xFFF59E0B),
    description:
        'Our flagship summer showcase featuring all levels and styles. Students perform choreography developed throughout the season on our main stage.',
  ),
  _Event(
    title: 'Starbound National Finals',
    date: 'Jul 10 – Jul 13, 2025',
    location: 'Orlando, FL',
    tag: 'Competition',
    tagColor: Color(0xFF3B82F6),
    description:
        'The national finals for Starbound Dance Competition. Competitors from across the country perform in jazz, ballet, contemporary, and hip hop categories.',
  ),
  _Event(
    title: 'City Dance Challenge',
    date: 'Aug 2 – Aug 3, 2025',
    location: 'Nashville, TN',
    tag: 'Competition',
    tagColor: Color(0xFF3B82F6),
    description:
        'A regional competition held in Nashville featuring group and solo performances across all dance styles and age groups.',
  ),
  _Event(
    title: 'Fall Invitational',
    date: 'Sep 20, 2025',
    location: 'Atlanta, GA',
    tag: 'Event',
    tagColor: Color(0xFF10B981),
    description:
        'An invitational event bringing together top studios from the Southeast for a day of performances and community celebration.',
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// AllEventsView
// ══════════════════════════════════════════════════════════════════════════════
class AllEventsView extends StatefulWidget {
  const AllEventsView({super.key});

  @override
  State<AllEventsView> createState() => _AllEventsViewState();
}

class _AllEventsViewState extends State<AllEventsView> {
  String _query = '';

  List<_Event> get _filtered => _kEvents
      .where((e) =>
          e.title.toLowerCase().contains(_query.toLowerCase()) ||
          e.location.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final events = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        title: const Text('All Events',
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
                  hintText: 'Search by title or location…',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
          // Event list
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text('No events found.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _EventCard(event: events[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _showDetail(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.emoji_events_outlined,
                  size: 26,
                  color: event.tagColor.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.date,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _TagBadge(label: event.tag, color: event.tagColor),
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
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: event.tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.emoji_events_outlined,
                        size: 28, color: event.tagColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      _TagBadge(label: event.tag, color: event.tagColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            _DetailLine(
                icon: Icons.calendar_today_outlined, label: 'Date', value: event.date),
            const SizedBox(height: 8),
            _DetailLine(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: event.location),
            const SizedBox(height: 16),
            Text('About this Event',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(event.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                          color: AppColors.textSecondary, height: 1.6)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Register',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 68,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
        ),
        Expanded(
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
