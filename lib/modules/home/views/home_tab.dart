import 'package:catalyst/app/routes/app_routes.dart';
import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/main/controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDashboard,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Header
                _Header(),
                const SizedBox(height: 20),
                // Stats cards
                _StatsRow(),
                const SizedBox(height: 20),
                // Quick Actions
                _QuickActions(),
                const SizedBox(height: 20),
                // Today's Classes
                _TodayClasses(),
                const SizedBox(height: 16),
                // Private Lessons Today
                _PrivateLessonsToday(),
                const SizedBox(height: 16),
                // Competitions
                _CompetitionsSection(),
                const SizedBox(height: 16),
                // Wellness
                _WellnessSection(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium),
          Obx(() => Text(
            controller.userName.value.split(' ').first,
            style: Theme.of(context).textTheme.headlineLarge,
          )),
        ],
      )),
      IconButton(
        onPressed: () => Get.toNamed(AppRoutes.notifications),
        icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
      ),
    ]);
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(children: [
      _StatTile(icon: Icons.school, label: 'Classes Today',
          value: '${controller.upcomingClassesCount.value}', color: AppColors.primary),
      const SizedBox(width: 8),
      _StatTile(icon: Icons.person, label: 'Private Lessons',
          value: '${controller.upcomingPrivateClassesCount.value}', color: AppColors.success),
      const SizedBox(width: 8),
      _StatTile(icon: Icons.emoji_events, label: 'Competitions',
          value: '${controller.competitionRemindersCount.value}', color: AppColors.warning),
    ]));
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon; final String label; final String value; final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ));
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.school_outlined, 'Classes', AppRoutes.regularClasses),
      _QA(Icons.person_pin, 'Private\nLessons', AppRoutes.privateLessons),
      _QA(Icons.payment, 'Payments', AppRoutes.payments),
      _QA(Icons.family_restroom, 'Family', AppRoutes.family),
    ];
    return Row(children: actions.map((a) => Expanded(child: GestureDetector(
      onTap: () => Get.toNamed(a.route),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Icon(a.icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(a.label, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 10)),
        ]),
      ),
    ))).toList());
  }
}

class _QA { const _QA(this.icon, this.label, this.route); final IconData icon; final String label; final String route; }

// ── Today's Classes ───────────────────────────────────────────────────────────
class _TodayClasses extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.upcomingClasses.toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Today's Classes", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // Date block
              Container(
                width: 50, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(c['date']?['month']?.toString() ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  Text(c['date']?['day']?.toString() ?? '', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(c['date']?['weekday']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c['name']?.toString() ?? '', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(c['time']?.toString() ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                Text(c['studio']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              if (c['tag'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(c['tag'].toString(), style: const TextStyle(color: AppColors.primary, fontSize: 9)),
                ),
            ]),
          ),
        )),
      ]);
    });
  }
}

// ── Private Lessons Today ─────────────────────────────────────────────────────
class _PrivateLessonsToday extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.upcomingPrivateClasses.toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Private Lessons Today", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Icon(Icons.person_pin, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['name']?.toString() ?? '', style: Theme.of(context).textTheme.titleSmall),
                Text(p['studio']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(p['status']?.toString() ?? 'Scheduled', style: const TextStyle(color: AppColors.success, fontSize: 9)),
              ),
            ]),
          ),
        )),
      ]);
    });
  }
}

// ── Competitions ──────────────────────────────────────────────────────────────
class _CompetitionsSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.competitions.toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Upcoming Competitions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            onTap: () => Get.toNamed(AppRoutes.competitions),
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              const Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c['name']?.toString() ?? '', style: Theme.of(context).textTheme.titleSmall),
                Text(c['location']?.toString() ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(c['status']?.toString() ?? '', style: const TextStyle(color: AppColors.warning, fontSize: 9)),
              ),
            ]),
          ),
        )),
      ]);
    });
  }
}

// ── Wellness ──────────────────────────────────────────────────────────────────
class _WellnessSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final w = controller.wellnessMembership.value;
      return AppCard(
        onTap: () => Get.toNamed(AppRoutes.wellness),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.wellness.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.spa, color: AppColors.wellness, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w != null ? w['productName']?.toString() ?? 'Wellness Pass' : 'No Active Pass',
                style: Theme.of(context).textTheme.titleSmall),
            Text(controller.wellnessStatus.value.isNotEmpty
                ? '${controller.wellnessStatus.value} • ${controller.creditsRemaining.value} credits left'
                : 'Get a wellness pass',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        ]),
      );
    });
  }
}
