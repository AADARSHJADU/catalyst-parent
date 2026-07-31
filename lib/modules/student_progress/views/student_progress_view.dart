import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Local data models ──────────────────────────────────────────────────────────
class _Skill {
  const _Skill(this.name, this.percent, this.color);
  final String name;
  final double percent;
  final Color color;
}

class _Feedback {
  const _Feedback(
      {required this.instructor,
      required this.date,
      required this.rating,
      required this.text});
  final String instructor;
  final String date;
  final int rating;
  final String text;
}

class _Goal {
  const _Goal(
      {required this.title,
      required this.dueDate,
      required this.progress,
      required this.color});
  final String title;
  final String dueDate;
  final double progress;
  final Color color;
}

class _ReportPoint {
  const _ReportPoint(this.label, this.value);
  final String label;
  final double value; // 0–1
}

// ── Mock data ──────────────────────────────────────────────────────────────────
const _skills = [
  _Skill('Technique', 0.90, Color(0xFF9C27B0)),
  _Skill('Performance', 0.80, Color(0xFF9C27B0)),
  _Skill('Musicality', 0.85, Color(0xFF9C27B0)),
  _Skill('Flexibility', 0.75, Color(0xFF9C27B0)),
];

const _feedbacks = [
  _Feedback(
    instructor: 'Ava Rodriguez',
    date: 'May 23, 2025',
    rating: 5,
    text:
        'Sarah shows great improvement in technique and musicality. Keep working on expression and stage presence. Proud of your progress!',
  ),
  _Feedback(
    instructor: 'Hannah Blake',
    date: 'May 15, 2025',
    rating: 4,
    text:
        'Great effort this week! Turns are coming along well. Focus on clean arm positions during combinations.',
  ),
  _Feedback(
    instructor: 'Liam Carter',
    date: 'May 8, 2025',
    rating: 5,
    text:
        'Excellent energy and stage presence during the jazz session. Keep building on that confidence!',
  ),
];

const _goals = [
  _Goal(
    title: 'Improve Turns',
    dueDate: 'Due: Jun 30, 2025',
    progress: 0.75,
    color: Color(0xFF2196F3),
  ),
  _Goal(
    title: 'Increase Flexibility',
    dueDate: 'Due: Jul 15, 2025',
    progress: 0.60,
    color: Color(0xFF2196F3),
  ),
  _Goal(
    title: 'Perfect Performance',
    dueDate: 'Due: Jun 10, 2025',
    progress: 0.90,
    color: Color(0xFF2196F3),
  ),
];

const _reportPoints = [
  _ReportPoint('Dec 2024', 0.50),
  _ReportPoint('Jan 2025', 0.60),
  _ReportPoint('Feb 2025', 0.68),
  _ReportPoint('Mar 2025', 0.75),
  _ReportPoint('Apr 2025', 0.82),
  _ReportPoint('May 2025', 0.87),
];

// ── View ───────────────────────────────────────────────────────────────────────
class StudentProgressView extends StatelessWidget {
  const StudentProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
        title: const Text('Student Progress'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ── Page header ────────────────────────────────────────────
          const SizedBox(height: 4),
          Text('Student Progress',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Track your skills, feedback, goals, and achievements.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          // ── Top row: Skill + Feedback + Goals ──────────────────────
          // On narrow screens → stack vertically; wide → row
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _SkillAssessmentsCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _InstructorFeedbackCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _GoalsTrackingCard()),
                ],
              );
            }
            return Column(children: [
              _SkillAssessmentsCard(),
              const SizedBox(height: 12),
              _InstructorFeedbackCard(),
              const SizedBox(height: 12),
              _GoalsTrackingCard(),
            ]);
          }),
          const SizedBox(height: 12),

          // ── Performance Reports ────────────────────────────────────
          _PerformanceReportsCard(),
          const SizedBox(height: 12),

          // ── Motivational banner ────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep up the great work! Consistent practice leads to excellence.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
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

// ═══════════════════════════════════════════════════════════════════════════════
// Skill Assessments card
// ═══════════════════════════════════════════════════════════════════════════════
class _SkillAssessmentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skill Assessments',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('View detailed skill evaluations',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Overall score ring + skill bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular progress
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: 0.85,
                        strokeWidth: 8,
                        backgroundColor:
                            AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF9C27B0)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('85%',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 20)),
                        Text('Overall',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                        Text('Score',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Skill bars
              Expanded(
                child: Column(
                  children: _skills
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SkillBar(skill: s),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          _ViewAllRow(
            label: 'View All Assessments',
            onTap: () => Get.snackbar(
                'Assessments', 'Full assessments coming soon',
                snackPosition: SnackPosition.BOTTOM),
          ),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.skill});
  final _Skill skill;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(skill.name,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: skill.percent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(skill.color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '${(skill.percent * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Instructor Feedback card
// ═══════════════════════════════════════════════════════════════════════════════
class _InstructorFeedbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final latest = _feedbacks.first;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Instructor Feedback',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text("See what your instructors are saying",
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Latest feedback
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  latest.instructor.split(' ').map((p) => p[0]).join(),
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(latest.instructor,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(latest.date,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stars
          Row(
            children: List.generate(
                5,
                (i) => Icon(
                      i < latest.rating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: AppColors.warning,
                    )),
          ),
          const SizedBox(height: 10),
          Text(
            latest.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          _ViewAllRow(
            label: 'View All Feedback',
            onTap: () => _showAllFeedback(context),
          ),
        ],
      ),
    );
  }

  void _showAllFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Text('All Feedback',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._feedbacks.map((f) => _FeedbackTile(feedback: f)),
          ],
        ),
      ),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  const _FeedbackTile({required this.feedback});
  final _Feedback feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  feedback.instructor.split(' ').map((p) => p[0]).join(),
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 11),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feedback.instructor,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textPrimary)),
                    Text(feedback.date,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < feedback.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: AppColors.warning,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.55,
                  )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Goals Tracking card
// ═══════════════════════════════════════════════════════════════════════════════
class _GoalsTrackingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.track_changes_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goals Tracking',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Monitor your progress toward goals',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Goals list
          ..._goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GoalItem(goal: g),
              )),

          const Divider(height: 1, color: AppColors.border),
          _ViewAllRow(
            label: 'View All Goals',
            onTap: () => Get.snackbar('Goals', 'All goals coming soon',
                snackPosition: SnackPosition.BOTTOM),
          ),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  const _GoalItem({required this.goal});
  final _Goal goal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(goal.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textPrimary)),
            ),
            Text(goal.dueDate,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(goal.color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(goal.progress * 100).toInt()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Performance Reports card
// ═══════════════════════════════════════════════════════════════════════════════
class _PerformanceReportsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Performance Reports',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Detailed insights into performance',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Score',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('87%',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trending_up,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('5% from last report',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.success)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _LineChart(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Month labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _reportPoints
                .map((p) => Text(p.label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 9)))
                .toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),

          // Footer row
          Row(
            children: [
              TextButton(
                onPressed: () => Get.snackbar(
                    'Report', 'Full report coming soon',
                    snackPosition: SnackPosition.BOTTOM),
                child: const Text('View Full Report',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Get.snackbar(
                    'Download', 'Report downloaded',
                    snackPosition: SnackPosition.BOTTOM),
                icon: const Icon(Icons.download_outlined,
                    size: 16, color: AppColors.primary),
                label: const Text('Download Report',
                    style: TextStyle(
                        color: AppColors.primary, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Custom line chart (no package needed) ─────────────────────────────────────
class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: _ChartPainter(),
        size: const Size(double.infinity, 100),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = _reportPoints;
    if (points.length < 2) return;

    final w = size.width;
    final h = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;
    for (final pct in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = h - (pct * h * 0.8) - h * 0.1;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Build point positions
    final coords = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * w;
      final y = h - (points[i].value * h * 0.8) - h * 0.1;
      coords.add(Offset(x, y));
    }

    // Fill area under curve
    final fillPath = Path()..moveTo(coords.first.dx, h);
    for (final c in coords) {
      fillPath.lineTo(c.dx, c.dy);
    }
    fillPath.lineTo(coords.last.dx, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (int i = 1; i < coords.length; i++) {
      linePath.lineTo(coords[i].dx, coords[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;

    for (final c in coords) {
      canvas.drawCircle(c, 5, dotBorder);
      canvas.drawCircle(c, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shared helpers ─────────────────────────────────────────────────────────────
class _ViewAllRow extends StatelessWidget {
  const _ViewAllRow({required this.label, required this.onTap});
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
