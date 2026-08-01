import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/student_evaluation_model.dart';
import 'package:catalyst/data/models/student_feedback_model.dart';
import 'package:catalyst/modules/student_progress/controllers/student_progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── View ───────────────────────────────────────────────────────────────────────
class StudentProgressView extends GetView<StudentProgressController> {
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.students.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              const SizedBox(height: 4),
              // ── Student selector ──────────────────────────────────
              if (controller.students.length > 1) ...[
                _StudentDropdown(),
                const SizedBox(height: 16),
              ],
              // ── Page header ────────────────────────────────────────
              Text('Student Progress',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Track skills, feedback, and attendance.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // ── Loading overlay for data ──────────────────────────
              if (controller.isDataLoading.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                // ── Attendance summary ────────────────────────────────
                _AttendanceSummaryCard(),
                const SizedBox(height: 12),

                // ── Skill Assessments ─────────────────────────────────
                _SkillAssessmentsCard(),
                const SizedBox(height: 12),

                // ── Instructor Feedback ───────────────────────────────
                _InstructorFeedbackCard(),
                const SizedBox(height: 12),

                // ── Performance Reports ───────────────────────────────
                _PerformanceReportsCard(),
                const SizedBox(height: 12),

                // ── Motivational banner ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Error state
// ═══════════════════════════════════════════════════════════════════════════════
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
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Student Dropdown Selector
// ═══════════════════════════════════════════════════════════════════════════════
class _StudentDropdown extends GetView<StudentProgressController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedStudent.value;
      return AppCard(
        child: DropdownButtonFormField<int>(
          value: selected?.id,
          decoration: const InputDecoration(
            labelText: 'Select Student',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: controller.students
              .map((s) => DropdownMenuItem<int>(
                    value: s.id,
                    child: Text(s.fullName),
                  ))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final student =
                controller.students.firstWhere((s) => s.id == id);
            controller.selectStudent(student);
          },
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Attendance Summary Card
// ═══════════════════════════════════════════════════════════════════════════════
class _AttendanceSummaryCard extends GetView<StudentProgressController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalClasses;
      final rate = controller.attendanceRate;
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('$total total classes',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rate >= 80
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${rate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: rate >= 80
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                    label: 'Present',
                    count: controller.presentCount,
                    color: AppColors.success),
                _StatChip(
                    label: 'Late',
                    count: controller.lateCount,
                    color: AppColors.warning),
                _StatChip(
                    label: 'Absent',
                    count: controller.absentCount,
                    color: AppColors.error),
                _StatChip(
                    label: 'Excused',
                    count: controller.excusedCount,
                    color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Skill Assessments Card
// ═══════════════════════════════════════════════════════════════════════════════
class _SkillAssessmentsCard extends GetView<StudentProgressController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final skills = controller.skillBreakdown;
      final overall = controller.overallScore;

      if (controller.evaluations.isEmpty) {
        return AppCard(
          child: _EmptySection(
            icon: Icons.assignment_outlined,
            title: 'Skill Assessments',
            message: 'No evaluations recorded yet.',
          ),
        );
      }

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
                      Text('Latest evaluation breakdown',
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
                          value: overall / 100.0,
                          strokeWidth: 8,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF9C27B0)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${overall.toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 20)),
                          Text('Overall',
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                          Text('Score',
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: skills.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _SkillBar(
                                  name: e.key, percent: e.value),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
            // ── Evaluation details ──────────────────────────────
            if (controller.evaluations.first.comments != null) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Text(
                controller.evaluations.first.comments!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
            if (controller.evaluations.first.goals != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Goal: ${controller.evaluations.first.goals}',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            _ViewAllRow(
              label: 'View All Evaluations (${controller.evaluations.length})',
              onTap: () => _showAllEvaluations(context),
            ),
          ],
        ),
      );
    });
  }

  void _showAllEvaluations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
            Text('All Evaluations',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...controller.evaluations
                .map((e) => _EvaluationTile(evaluation: e)),
          ],
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.name, required this.percent});
  final String name;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child:
              Text(name, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF9C27B0)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '${(percent * 100).toInt()}%',
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

class _EvaluationTile extends StatelessWidget {
  const _EvaluationTile({required this.evaluation});
  final StudentEvaluationModel evaluation;

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
              Expanded(
                child: Text(
                  evaluation.term ?? evaluation.date,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${evaluation.overallScore.toInt()}%',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (evaluation.instructor != null) ...[
            const SizedBox(height: 6),
            Text(
              'By ${evaluation.instructor!.fullName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (evaluation.comments != null &&
              evaluation.comments!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              evaluation.comments!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
          if (evaluation.goals != null &&
              evaluation.goals!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag_outlined,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    evaluation.goals!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Instructor Feedback Card
// ═══════════════════════════════════════════════════════════════════════════════
class _InstructorFeedbackCard extends GetView<StudentProgressController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.feedbackList.isEmpty) {
        return AppCard(
          child: _EmptySection(
            icon: Icons.chat_bubble_outline,
            title: 'Instructor Feedback',
            message: 'No feedback available yet.',
          ),
        );
      }

      final latest = controller.feedbackList.first;
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
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      Text("What your instructors are saying",
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
            _FeedbackItem(feedback: latest),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            _ViewAllRow(
              label:
                  'View All Feedback (${controller.feedbackList.length})',
              onTap: () => _showAllFeedback(context),
            ),
          ],
        ),
      );
    });
  }

  void _showAllFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
            ...controller.feedbackList
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeedbackItem(feedback: f),
                    )),
          ],
        ),
      ),
    );
  }
}

class _FeedbackItem extends StatelessWidget {
  const _FeedbackItem({required this.feedback});
  final StudentFeedbackModel feedback;

  @override
  Widget build(BuildContext context) {
    final instructorName =
        feedback.instructor?.fullName ?? 'Instructor';
    final initials = instructorName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join();

    return Container(
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
                radius: 20,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.2),
                child: Text(initials,
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(instructorName,
                        style:
                            Theme.of(context).textTheme.titleSmall),
                    Text(feedback.date,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback.type,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 11),
                ),
              ),
            ],
          ),
          if (feedback.notesToParent != null &&
              feedback.notesToParent!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              feedback.notesToParent!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
            ),
          ] else if (feedback.summary != null &&
              feedback.summary!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              feedback.summary!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Performance Reports Card (line chart from evaluations over time)
// ═══════════════════════════════════════════════════════════════════════════════
class _PerformanceReportsCard extends GetView<StudentProgressController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final trend = controller.progressTrend;
      if (trend.isEmpty) {
        return AppCard(
          child: _EmptySection(
            icon: Icons.bar_chart_outlined,
            title: 'Performance Reports',
            message: 'Not enough data for performance trends.',
          ),
        );
      }

      final latestScore = controller.overallScore;
      // Calculate improvement vs previous if available
      String? improvement;
      if (controller.evaluations.length >= 2) {
        final sorted = [...controller.evaluations]
          ..sort((a, b) => a.date.compareTo(b.date));
        final prev = sorted[sorted.length - 2].overallScore;
        final curr = sorted.last.overallScore;
        final diff = curr - prev;
        if (diff > 0) {
          improvement = '+${diff.toStringAsFixed(0)}% from last report';
        } else if (diff < 0) {
          improvement = '${diff.toStringAsFixed(0)}% from last report';
        }
      }

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
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      Text('Progress over time',
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
                    Text('${latestScore.toInt()}%',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: AppColors.primary)),
                    if (improvement != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            improvement.startsWith('+')
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: improvement.startsWith('+')
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(improvement,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: improvement.startsWith('+')
                                        ? AppColors.success
                                        : AppColors.error,
                                  )),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(child: _LineChart(data: trend)),
              ],
            ),
            const SizedBox(height: 16),
            // Month labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: trend
                  .map((p) => Flexible(
                        child: Text(
                          (p['label'] as String).length > 8
                              ? (p['label'] as String).substring(0, 8)
                              : p['label'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }
}

// ── Custom line chart ─────────────────────────────────────────────────────────
class _LineChart extends StatelessWidget {
  const _LineChart({required this.data});
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: _ChartPainter(data),
        size: const Size(double.infinity, 100),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.data);
  final List<Map<String, dynamic>> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

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
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * w;
      final value = (data[i]['value'] as double).clamp(0.0, 1.0);
      final y = h - (value * h * 0.8) - h * 0.1;
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
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.data != data;
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

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
