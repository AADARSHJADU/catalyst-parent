import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/models.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassDetailView extends GetView<ScheduleController> {
  const ClassDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cls = controller.selectedClass;
    if (cls == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Class Details')),
        body: const Center(child: Text('Class not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
        ),
        title: const Text('Class Details'),
      ),
      // ── Fixed bottom buttons ───────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: 'bookClass',
                onPressed: cls.spotsLeft == 0
                    ? null
                    : () {
                        controller.resetClassBooking();
                        Get.toNamed(AppRoutes.bookClass);
                      },
                backgroundColor: cls.spotsLeft == 0
                    ? AppColors.border
                    : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.calendar_month_outlined,
                    size: 18),
                label: Text(
                  cls.spotsLeft == 0
                      ? 'Class is Full'
                      : 'Book This Class',
                  style: const TextStyle(
                      fontSize: 14, letterSpacing: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: 'addToCalendar',
                onPressed: () => Get.snackbar(
                  'Calendar',
                  'Added to your calendar',
                  snackPosition: SnackPosition.BOTTOM,
                ),
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.textPrimary,
                elevation: 1,
                icon: const Icon(Icons.calendar_today_outlined,
                    size: 16),
                label: const Text('Add to Calendar',
                    style: TextStyle(fontSize: 13)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Details',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'View full information about this class.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            // Main content row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _ClassHeaderCard(cls: cls),
                            const SizedBox(height: 16),
                            _ClassTabsCard(cls: cls),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 280,
                        child: Column(
                          children: [
                            _InstructorCard(cls: cls),
                            const SizedBox(height: 16),
                            _ClassDetailsCard(cls: cls),
                            const SizedBox(height: 16),
                            _EnrolledStudentsCard(cls: cls),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _ClassHeaderCard(cls: cls),
                    const SizedBox(height: 16),
                    _InstructorCard(cls: cls),
                    const SizedBox(height: 16),
                    _ClassDetailsCard(cls: cls),
                    const SizedBox(height: 16),
                    _EnrolledStudentsCard(cls: cls),
                    const SizedBox(height: 16),
                    _ClassTabsCard(cls: cls),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header card ────────────────────────────────────────────────────────────────
class _ClassHeaderCard extends StatelessWidget {
  const _ClassHeaderCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: AppColors.surface,
              child: Center(
                child: Icon(
                  Icons.sports_gymnastics,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LevelDot(level: cls.level),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cls.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${cls.enrolled} / ${cls.capacity}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        Text(
                          'Enrolled',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TagChip(label: cls.ageRange),
                    const SizedBox(width: 8),
                    _TagChip(label: 'Level: ${cls.level}'),
                  ],
                ),
                const SizedBox(height: 16),
                _IconRow(
                    icon: Icons.calendar_today_outlined, text: cls.fullDate),
                const SizedBox(height: 6),
                _IconRow(
                  icon: Icons.access_time_outlined,
                  text:
                      '${cls.startTime} – ${cls.endTime} (${cls.timezone})',
                ),
                const SizedBox(height: 6),
                _IconRow(
                    icon: Icons.location_on_outlined, text: cls.room),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar('Share', 'Link copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    icon: const Icon(Icons.share_outlined,
                        size: 16, color: AppColors.primary),
                    label: const Text('Share Class',
                        style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── About / What to Expect tabs ────────────────────────────────────────────────
class _ClassTabsCard extends StatefulWidget {
  const _ClassTabsCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  State<_ClassTabsCard> createState() => _ClassTabsCardState();
}

class _ClassTabsCardState extends State<_ClassTabsCard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab row
          Row(
            children: [
              _TabButton(
                label: 'About This Class',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 16),
              _TabButton(
                label: 'What to Expect',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          if (_tab == 0) ...[
            Text(
              widget.cls.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 20),
            Text('What Dancers Will Learn',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ..._learnItems(widget.cls.danceStyle)
                .map((item) => _CheckItem(text: item)),
            const SizedBox(height: 20),
            Text('Please Bring',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _bringItems(widget.cls.danceStyle)
                  .map((item) => _BringChip(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String))
                  .toList(),
            ),
            if (widget.cls.isRecurring) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.repeat,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This is a recurring class',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textPrimary)),
                          Text(widget.cls.recurringNote,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              'Class Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Each session starts with a warm-up, moves into the main technique or choreography segment, and closes with a cool-down and instructor feedback.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
            _CheckItem(
                text:
                    'Warm-up & conditioning (${(widget.cls.durationMinutes * 0.2).toInt()} mins)'),
            _CheckItem(
                text:
                    'Technique & combinations (${(widget.cls.durationMinutes * 0.6).toInt()} mins)'),
            _CheckItem(
                text:
                    'Cool-down & feedback (${(widget.cls.durationMinutes * 0.2).toInt()} mins)'),
          ],
        ],
      ),
    );
  }

  List<String> _learnItems(String style) {
    if (style.toLowerCase().contains('ballet')) {
      return [
        'Advanced ballet technique and terminology',
        'Improved posture, alignment, and balance',
        'Center work, barre, and across-the-floor combinations',
        'Performance quality and expression',
      ];
    }
    if (style.toLowerCase().contains('hip hop')) {
      return [
        'Foundation hip hop grooves and isolations',
        'Rhythm and musicality exercises',
        'Short choreography combinations',
        'Performance confidence',
      ];
    }
    return [
      'Core technique for the style',
      'Strength and flexibility fundamentals',
      'Coordination and musicality',
      'Performance quality and artistry',
    ];
  }

  List<Map<String, dynamic>> _bringItems(String style) {
    final base = [
      {'icon': Icons.water_drop_outlined, 'label': 'Water bottle'},
      {'icon': Icons.checkroom_outlined, 'label': 'Comfortable dancewear'},
    ];
    if (style.toLowerCase().contains('ballet')) {
      return [
        {'icon': Icons.directions_walk_outlined, 'label': 'Ballet shoes'},
        ...base,
        {'icon': Icons.face_retouching_natural, 'label': 'Hair in a bun'},
      ];
    }
    if (style.toLowerCase().contains('tap')) {
      return [
        {'icon': Icons.directions_walk_outlined, 'label': 'Tap shoes'},
        ...base,
      ];
    }
    return [
      {'icon': Icons.directions_run_outlined, 'label': 'Dance shoes'},
      ...base,
    ];
  }
}

// ── Instructor card ─────────────────────────────────────────────────────────────
class _InstructorCard extends StatelessWidget {
  const _InstructorCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instructor',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  cls.instructor.split(' ').last[0],
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.instructor,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(cls.danceStyle.isEmpty ? 'Dance' : cls.danceStyle,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('5.0',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textPrimary)),
                        const SizedBox(width: 4),
                        Text('(128 reviews)',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final ctrl = Get.find<ScheduleController>();
                ctrl.selectInstructorByName(cls.instructor);
                Get.toNamed(AppRoutes.instructorDetail);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Instructor Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Class Details card ──────────────────────────────────────────────────────────
class _ClassDetailsCard extends StatelessWidget {
  const _ClassDetailsCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Class Details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _DetailRow(
              icon: Icons.class_outlined,
              label: 'Class Type',
              value: cls.classType),
          _DetailRow(
              icon: Icons.music_note_outlined,
              label: 'Dance Style',
              value: cls.danceStyle.isEmpty ? cls.title : cls.danceStyle),
          _DetailRow(
              icon: Icons.bar_chart_outlined,
              label: 'Level',
              value: cls.level),
          _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${cls.durationMinutes} minutes'),
          _DetailRow(
              icon: Icons.group_outlined,
              label: 'Class Size',
              value: '${cls.enrolled} / ${cls.capacity} students'),
          _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Studio',
              value: cls.room),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Enrolled students card ──────────────────────────────────────────────────────
class _EnrolledStudentsCard extends StatelessWidget {
  const _EnrolledStudentsCard({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    final count = cls.enrolled;
    final show = count.clamp(0, 5);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Students Enrolled ($count)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(show, (i) {
                return Align(
                  widthFactor: 0.7,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _avatarColor(i),
                    child: Text(
                      _avatarInitials[i % _avatarInitials.length],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
              if (count > 5)
                Align(
                  widthFactor: 0.7,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      '+${count - 5}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(int i) {
    const colors = [
      Color(0xFF5C6BC0),
      Color(0xFFEC407A),
      Color(0xFF26A69A),
      Color(0xFFAB47BC),
      Color(0xFFEF5350),
    ];
    return colors[i % colors.length];
  }

  static const _avatarInitials = ['AJ', 'LK', 'MR', 'SP', 'OB'];
}

// ── Action buttons ──────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.cls});
  final ClassScheduleModel cls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Booking',
                'Sign in to book ${cls.title}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: const Text('Book This Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.snackbar('Calendar', 'Added to your calendar',
                  snackPosition: SnackPosition.BOTTOM);
            },
            icon: const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textPrimary),
            label: const Text('Add to Calendar',
                style: TextStyle(color: AppColors.textPrimary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────────
class _LevelDot extends StatelessWidget {
  const _LevelDot({required this.level});
  final String level;

  Color get _color {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFF9C27B0);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          const SizedBox(height: 4),
          if (selected)
            Container(
              height: 2,
              width: label.length * 7.5,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
          ),
        ],
      ),
    );
  }
}

class _BringChip extends StatelessWidget {
  const _BringChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
