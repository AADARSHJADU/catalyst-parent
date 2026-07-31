import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/competitions/views/all_events_view.dart';
import 'package:catalyst/modules/competitions/views/all_results_view.dart';
import 'package:catalyst/modules/competitions/views/event_calendar_view.dart';
import 'package:catalyst/modules/competitions/views/full_schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Models ─────────────────────────────────────────────────────────────────────
class _Event {
  const _Event({
    required this.title,
    required this.date,
    required this.location,
    required this.tag,
    required this.tagColor,
  });
  final String title;
  final String date;
  final String location;
  final String tag;
  final Color tagColor;
}

class _Reg {
  const _Reg({required this.event, required this.date, required this.status});
  final String event;
  final String date;
  final String status;
}

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

// ── Mock data ──────────────────────────────────────────────────────────────────
const _kEvents = [
  _Event(
    title: 'Summer Showcase 2025',
    date: 'Jun 21, 2025 · 6:00 PM',
    location: 'Catalyst Dance Theater',
    tag: 'Featured',
    tagColor: Color(0xFFF59E0B),
  ),
  _Event(
    title: 'Starbound National Finals',
    date: 'Jul 10 – Jul 13, 2025',
    location: 'Orlando, FL',
    tag: 'Competition',
    tagColor: Color(0xFF3B82F6),
  ),
  _Event(
    title: 'City Dance Challenge',
    date: 'Aug 2 – Aug 3, 2025',
    location: 'Nashville, TN',
    tag: 'Competition',
    tagColor: Color(0xFF3B82F6),
  ),
  _Event(
    title: 'Fall Invitational',
    date: 'Sep 20, 2025',
    location: 'Atlanta, GA',
    tag: 'Event',
    tagColor: Color(0xFF10B981),
  ),
];

const _kRegs = [
  _Reg(event: 'Summer Showcase 2025', date: 'Jun 21, 2025', status: 'registered'),
  _Reg(event: 'Starbound National Finals', date: 'Jul 10 – Jul 13, 2025', status: 'registered'),
  _Reg(event: 'City Dance Challenge', date: 'Aug 2 – Aug 3, 2025', status: 'pending'),
  _Reg(event: 'Fall Invitational', date: 'Sep 20, 2025', status: 'not_registered'),
];

final _kSchedDays = [
  const _SchedDay(label: 'Thu, Jul 10', items: [
    _SchedItem(time: '8:00 AM', title: 'Check-In', location: 'Convention Center', dotColor: Color(0xFF9C27B0)),
    _SchedItem(time: '9:00 AM', title: 'Warm-Up', location: 'Room A', dotColor: Color(0xFFF59E0B)),
    _SchedItem(time: '10:00 AM', title: 'Jazz – Advanced Competition', location: 'Main Stage', dotColor: AppColors.primary),
    _SchedItem(time: '2:30 PM', title: 'Awards Ceremony', location: 'Main Stage', dotColor: Color(0xFF3B82F6)),
  ]),
  const _SchedDay(label: 'Fri, Jul 11', items: [
    _SchedItem(time: '9:00 AM', title: 'Ballet – Intermediate', location: 'Studio B', dotColor: Color(0xFF9C27B0)),
    _SchedItem(time: '1:00 PM', title: 'Contemporary – Advanced', location: 'Main Stage', dotColor: AppColors.primary),
  ]),
  const _SchedDay(label: 'Sat, Jul 12', items: [
    _SchedItem(time: '10:00 AM', title: 'Hip Hop – Beginner', location: 'Room C', dotColor: Color(0xFF10B981)),
    _SchedItem(time: '3:00 PM', title: 'Group Performance', location: 'Main Stage', dotColor: AppColors.primary),
  ]),
  const _SchedDay(label: 'Sun, Jul 13', items: [
    _SchedItem(time: '11:00 AM', title: 'Finals – All Styles', location: 'Main Stage', dotColor: Color(0xFFF59E0B)),
    _SchedItem(time: '4:00 PM', title: 'Closing Awards', location: 'Main Stage', dotColor: Color(0xFF3B82F6)),
  ]),
];

const _kResults = [
  _Result(
    event: 'Spring Dance Classic',
    dates: 'May 3 – May 4, 2025',
    category: 'Jazz – Advanced',
    result: '1st Place',
    score: '94.5 / 100',
    feedback: 'Excellent technique, great stage presence!',
    place: 1,
  ),
  _Result(
    event: 'Showtime Nationals',
    dates: 'Apr 10 – Apr 13, 2025',
    category: 'Contemporary – Intermediate',
    result: '2nd Place',
    score: '91.0 / 100',
    feedback: 'Strong performance, work on transitions.',
    place: 2,
  ),
  _Result(
    event: 'Revolution Dance Challenge',
    dates: 'Mar 22 – Mar 23, 2025',
    category: 'Hip Hop – Beginner',
    result: '3rd Place',
    score: '88.0 / 100',
    feedback: 'Great energy and improvement!',
    place: 3,
  ),
];

// ── Helper: trophy colour ──────────────────────────────────────────────────────
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
// Main view
// ══════════════════════════════════════════════════════════════════════════════
class CompetitionsView extends StatefulWidget {
  const CompetitionsView({super.key});

  @override
  State<CompetitionsView> createState() => _CompetitionsViewState();
}

class _CompetitionsViewState extends State<CompetitionsView> {
  int _selDay = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Competitions & Events'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SizedBox(height: 4),
          Text('Competitions & Events', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Discover upcoming events, track your registrations, and view results.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          // Upcoming Events
          _UpcomingCard(),
          const SizedBox(height: 12),

          // Registration Status
          _RegistrationCard(),
          const SizedBox(height: 12),

          // Event Schedule
          _ScheduleCard(selDay: _selDay, onDay: (i) => setState(() => _selDay = i)),
          const SizedBox(height: 12),

          // Results & Feedback
          _ResultsCard(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Upcoming Events Card
// ══════════════════════════════════════════════════════════════════════════════
class _UpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.event_outlined,
            iconBg: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
            title: 'Upcoming Events',
            subtitle: 'Mark your calendar for these exciting events.',
            trailing: TextButton(
              onPressed: () => Get.to(() => const AllEventsView()),
              child: const Text('View All',
                  style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ..._kEvents.map((e) => _EventTile(event: e)),
          const Divider(height: 1, color: AppColors.border),
          _Footer(label: 'View Full Event Calendar', onTap: () => Get.to(() => const EventCalendarView())),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final _Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Icon(Icons.emoji_events_outlined,
                  size: 24, color: AppColors.primary.withValues(alpha: 0.5)),
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
                _IconText(icon: Icons.calendar_today_outlined, text: event.date),
                const SizedBox(height: 2),
                _IconText(icon: Icons.location_on_outlined, text: event.location),
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

// ══════════════════════════════════════════════════════════════════════════════
// Registration Status Card
// ══════════════════════════════════════════════════════════════════════════════
class _RegistrationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.assignment_turned_in_outlined,
            iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.12),
            iconColor: const Color(0xFF3B82F6),
            title: 'Registration Status',
            subtitle: 'Track your registrations and participation.',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ..._kRegs.map((r) => _RegTile(reg: r)),
          const Divider(height: 1, color: AppColors.border),
          _Footer(label: 'Manage Registrations', onTap: () => Get.to(() => const AllEventsView())),
        ],
      ),
    );
  }
}

class _RegTile extends StatelessWidget {
  const _RegTile({required this.reg});
  final _Reg reg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reg.event,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                _IconText(icon: Icons.calendar_today_outlined, text: reg.date),
              ],
            ),
          ),
          _StatusChip(status: reg.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'registered':
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        label = 'Registered';
        break;
      case 'pending':
        color = AppColors.warning;
        icon = Icons.access_time_outlined;
        label = 'Pending';
        break;
      default:
        color = AppColors.textMuted;
        icon = Icons.radio_button_unchecked;
        label = 'Not Registered';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Event Schedule Card
// ══════════════════════════════════════════════════════════════════════════════
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.selDay, required this.onDay});
  final int selDay;
  final void Function(int) onDay;

  @override
  Widget build(BuildContext context) {
    final items = _kSchedDays[selDay].items;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.schedule_outlined,
            iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.12),
            iconColor: const Color(0xFF3B82F6),
            title: 'Event Schedule',
            subtitle: 'Your schedule for registered events.',
          ),
          const SizedBox(height: 10),
          Text('Starbound National Finals',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textPrimary)),
          Text('Jul 10 – Jul 13, 2025 • Orlando, FL',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          // Day tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_kSchedDays.length, (i) {
                final sel = i == selDay;
                return GestureDetector(
                  onTap: () => onDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      _kSchedDays[i].label,
                      style: TextStyle(
                        color: sel ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ...items.map((item) => _SchedRow(item: item)),
          const Divider(height: 1, color: AppColors.border),
          _Footer(label: 'View Full Schedule', onTap: () => Get.to(() => const FullScheduleView())),
        ],
      ),
    );
  }
}

class _SchedRow extends StatelessWidget {
  const _SchedRow({required this.item});
  final _SchedItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
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
            decoration:
                BoxDecoration(color: item.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                Text(item.location,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Results & Feedback Card
// ══════════════════════════════════════════════════════════════════════════════
class _ResultsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.emoji_events_outlined,
            iconBg: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
            title: 'Results & Feedback',
            subtitle: 'View results and feedback from past events.',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          // Table header
          Row(
            children: const [
              _TH(label: 'Event', flex: 3),
              _TH(label: 'Category', flex: 2),
              _TH(label: 'Result', flex: 2),
              _TH(label: 'Score', flex: 2),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          ..._kResults.asMap().entries.map((e) {
            final i = e.key;
            final r = e.value;
            return Column(
              children: [
                _ResultRow(result: r),
                if (i < _kResults.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
          const Divider(height: 1, color: AppColors.border),
          _Footer(label: 'View All Results & Feedback', onTap: () => Get.to(() => const AllResultsView())),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});
  final _Result result;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event + dates
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Icon(Icons.emoji_events_outlined,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.6)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.event,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                        Text(result.dates,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: Text(result.category,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ),
            // Result
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.emoji_events,
                      size: 13, color: _trophyColor(result.place)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(result.result,
                        style: TextStyle(
                            color: _trophyColor(result.place), fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            // Score
            Expanded(
              flex: 2,
              child: Text(result.score,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                    color: _trophyColor(result.place).withValues(alpha: 0.12),
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
                          style: Theme.of(context).textTheme.titleMedium),
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
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(result.feedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary, height: 1.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared widgets
// ══════════════════════════════════════════════════════════════════════════════
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

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

class _Footer extends StatelessWidget {
  const _Footer({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
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

class _TH extends StatelessWidget {
  const _TH({required this.label, required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted)),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

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
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
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
