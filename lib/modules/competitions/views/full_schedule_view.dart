import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Models (local copy) ───────────────────────────────────────────────────────
class _SchedDay {
  const _SchedDay({required this.label, required this.items});
  final String label;
  final List<_SchedItem> items;
}

class _SchedItem {
  const _SchedItem({
    required this.time,
    required this.title,
    required this.location,
    required this.dotColor,
  });
  final String time;
  final String title;
  final String location;
  final Color dotColor;
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final _kSchedDays = [
  const _SchedDay(label: 'Thu, Jul 10', items: [
    _SchedItem(
        time: '8:00 AM',
        title: 'Check-In & Registration',
        location: 'Convention Center – Main Lobby',
        dotColor: Color(0xFF9C27B0)),
    _SchedItem(
        time: '9:00 AM',
        title: 'Warm-Up Session',
        location: 'Room A – Practice Floor',
        dotColor: Color(0xFFF59E0B)),
    _SchedItem(
        time: '10:00 AM',
        title: 'Jazz – Advanced Competition',
        location: 'Main Stage',
        dotColor: AppColors.primary),
    _SchedItem(
        time: '12:30 PM',
        title: 'Lunch Break',
        location: 'Concourse Level',
        dotColor: Color(0xFF10B981)),
    _SchedItem(
        time: '2:30 PM',
        title: 'Awards Ceremony',
        location: 'Main Stage',
        dotColor: Color(0xFF3B82F6)),
    _SchedItem(
        time: '4:00 PM',
        title: 'End of Day',
        location: '',
        dotColor: AppColors.textMuted),
  ]),
  const _SchedDay(label: 'Fri, Jul 11', items: [
    _SchedItem(
        time: '9:00 AM',
        title: 'Ballet – Intermediate',
        location: 'Studio B',
        dotColor: Color(0xFF9C27B0)),
    _SchedItem(
        time: '11:00 AM',
        title: 'Tap – Beginner',
        location: 'Room C',
        dotColor: Color(0xFFF59E0B)),
    _SchedItem(
        time: '1:00 PM',
        title: 'Contemporary – Advanced',
        location: 'Main Stage',
        dotColor: AppColors.primary),
    _SchedItem(
        time: '3:30 PM',
        title: 'Evening Showcase',
        location: 'Main Stage',
        dotColor: Color(0xFF3B82F6)),
  ]),
  const _SchedDay(label: 'Sat, Jul 12', items: [
    _SchedItem(
        time: '10:00 AM',
        title: 'Hip Hop – Beginner',
        location: 'Room C',
        dotColor: Color(0xFF10B981)),
    _SchedItem(
        time: '12:00 PM',
        title: 'Lyrical – Intermediate',
        location: 'Studio B',
        dotColor: Color(0xFFF59E0B)),
    _SchedItem(
        time: '3:00 PM',
        title: 'Group Performance',
        location: 'Main Stage',
        dotColor: AppColors.primary),
    _SchedItem(
        time: '5:30 PM',
        title: 'Gala Dinner',
        location: 'Ballroom',
        dotColor: Color(0xFF9C27B0)),
  ]),
  const _SchedDay(label: 'Sun, Jul 13', items: [
    _SchedItem(
        time: '11:00 AM',
        title: 'Finals – All Styles',
        location: 'Main Stage',
        dotColor: Color(0xFFF59E0B)),
    _SchedItem(
        time: '2:00 PM',
        title: 'Judges\' Panel Q&A',
        location: 'Studio B',
        dotColor: AppColors.primary),
    _SchedItem(
        time: '4:00 PM',
        title: 'Closing Awards Ceremony',
        location: 'Main Stage',
        dotColor: Color(0xFF3B82F6)),
    _SchedItem(
        time: '5:30 PM',
        title: 'Farewell Reception',
        location: 'Concourse Level',
        dotColor: Color(0xFF10B981)),
  ]),
];

// ══════════════════════════════════════════════════════════════════════════════
// FullScheduleView
// ══════════════════════════════════════════════════════════════════════════════
class FullScheduleView extends StatefulWidget {
  const FullScheduleView({super.key});

  @override
  State<FullScheduleView> createState() => _FullScheduleViewState();
}

class _FullScheduleViewState extends State<FullScheduleView> {
  int _selDay = 0;

  @override
  Widget build(BuildContext context) {
    final items = _kSchedDays[_selDay].items;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        title: const Text('Full Event Schedule',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Event header
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.schedule_outlined,
                            size: 18, color: Color(0xFF3B82F6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Starbound National Finals',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 11, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text('Jul 10 – Jul 13, 2025',
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_outlined,
                                  size: 11, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text('Orlando, FL',
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Day tabs
          Text('Select Day',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_kSchedDays.length, (i) {
                final sel = i == _selDay;
                return GestureDetector(
                  onTap: () => setState(() => _selDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border,
                          width: 0.5),
                    ),
                    child: Text(
                      _kSchedDays[i].label,
                      style: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Schedule items
          Text(
            _kSchedDays[_selDay].label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _SchedRow(item: item),
                    if (idx < items.length - 1)
                      const Divider(height: 1, color: AppColors.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule row ──────────────────────────────────────────────────────────────
class _SchedRow extends StatelessWidget {
  const _SchedRow({required this.item});
  final _SchedItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(item.time,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textPrimary)),
          ),
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
                color: item.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                if (item.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(item.location,
                            style:
                                Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
