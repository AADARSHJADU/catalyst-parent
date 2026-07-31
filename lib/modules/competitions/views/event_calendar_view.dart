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
    required this.dateTime,
  });
  final String title;
  final String date;
  final String location;
  final String tag;
  final Color tagColor;
  final DateTime dateTime;
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final _kEvents = [
  _Event(
    title: 'Summer Showcase 2025',
    date: 'Jun 21, 2025 · 6:00 PM',
    location: 'Catalyst Dance Theater',
    tag: 'Featured',
    tagColor: const Color(0xFFF59E0B),
    dateTime: DateTime(2025, 6, 21),
  ),
  _Event(
    title: 'Starbound National Finals',
    date: 'Jul 10 – Jul 13, 2025',
    location: 'Orlando, FL',
    tag: 'Competition',
    tagColor: const Color(0xFF3B82F6),
    dateTime: DateTime(2025, 7, 10),
  ),
  _Event(
    title: 'City Dance Challenge',
    date: 'Aug 2 – Aug 3, 2025',
    location: 'Nashville, TN',
    tag: 'Competition',
    tagColor: const Color(0xFF3B82F6),
    dateTime: DateTime(2025, 8, 2),
  ),
  _Event(
    title: 'Fall Invitational',
    date: 'Sep 20, 2025',
    location: 'Atlanta, GA',
    tag: 'Event',
    tagColor: const Color(0xFF10B981),
    dateTime: DateTime(2025, 9, 20),
  ),
];

const _kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

// ══════════════════════════════════════════════════════════════════════════════
// EventCalendarView
// ══════════════════════════════════════════════════════════════════════════════
class EventCalendarView extends StatefulWidget {
  const EventCalendarView({super.key});

  @override
  State<EventCalendarView> createState() => _EventCalendarViewState();
}

class _EventCalendarViewState extends State<EventCalendarView> {
  late DateTime _month;
  DateTime? _selectedDay;
  _Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _nextMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month + 1));

  _Event? _eventForDay(DateTime day) {
    for (final e in _kEvents) {
      if (e.dateTime.year == day.year &&
          e.dateTime.month == day.month &&
          e.dateTime.day == day.day) {
        return e;
      }
    }
    return null;
  }

  // Group upcoming events by month label
  Map<String, List<_Event>> get _grouped {
    final now = DateTime.now();
    final upcoming = _kEvents.where((e) => !e.dateTime.isBefore(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final map = <String, List<_Event>>{};
    for (final e in upcoming) {
      final key = '${_kMonths[e.dateTime.month - 1]} ${e.dateTime.year}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: Get.back,
        ),
        title: const Text('Event Calendar',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Calendar card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month/year header with navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_kMonths[_month.month - 1]} ${_month.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Day-of-week headers
                Row(
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map(
                        (d) => Expanded(
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                _buildCalendarGrid(),
                // Selected day event panel
                if (_selectedEvent != null) ...[
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 10),
                  _SelectedEventTile(event: _selectedEvent!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Upcoming events grouped by month
          Text('Upcoming Events',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._grouped.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  ...entry.value.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UpcomingEventRow(event: e),
                      )),
                  const SizedBox(height: 8),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final day = DateTime(_month.year, _month.month, dayNum);
              final event = _eventForDay(day);
              final isSelected = _selectedDay?.year == day.year &&
                  _selectedDay?.month == day.month &&
                  _selectedDay?.day == day.day;
              final isToday = DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (event != null) {
                      setState(() {
                        _selectedDay = day;
                        _selectedEvent = event;
                      });
                    } else {
                      setState(() {
                        _selectedDay = day;
                        _selectedEvent = null;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        if (event != null)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : event.tagColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ── Selected event panel ──────────────────────────────────────────────────────
class _SelectedEventTile extends StatelessWidget {
  const _SelectedEventTile({required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.tagColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: event.tagColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: event.tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.emoji_events_outlined,
                  size: 20, color: event.tagColor),
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
                const SizedBox(height: 2),
                Text(event.location,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          _TagBadge(label: event.tag, color: event.tagColor),
        ],
      ),
    );
  }
}

// ── Upcoming event row ────────────────────────────────────────────────────────
class _UpcomingEventRow extends StatelessWidget {
  const _UpcomingEventRow({required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: event.tagColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${event.dateTime.day}',
                  style: TextStyle(
                    color: event.tagColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  _kMonths[event.dateTime.month - 1].substring(0, 3),
                  style: TextStyle(
                    color: event.tagColor.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
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
