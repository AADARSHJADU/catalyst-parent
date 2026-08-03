import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/modules/wellness_new/controllers/wellness_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String _fixImg(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    return url.replaceAll('http://localhost:8080',
        'https://darksalmon-dragonfly-928313.hostingersite.com');
  }
  if (!url.startsWith('http')) {
    return 'https://darksalmon-dragonfly-928313.hostingersite.com$url';
  }
  return url;
}

String _numStr(dynamic v) {
  if (v is num) return v.toStringAsFixed(2);
  return double.tryParse(v.toString())?.toStringAsFixed(2) ?? v.toString();
}

class WellnessNewView extends GetView<WellnessNewController> {
  const WellnessNewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.wellness));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.classes.isEmpty) {
          return _buildError();
        }
        return Obx(() => IndexedStack(
              index: controller.currentTab.value,
              children: const [
                _HomeTab(),
                _MembershipTab(),
                _BuyPassesTab(),
                _ClassesTab(),
                _MyBookingsTab(),
              ],
            ));
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentTab.value,
            onTap: (i) => controller.currentTab.value = i,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.card,
            selectedItemColor: AppColors.wellness,
            unselectedItemColor: AppColors.textMuted,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.card_membership_outlined),
                  activeIcon: Icon(Icons.card_membership),
                  label: 'Membership'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Buy Pass'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.spa_outlined),
                  activeIcon: Icon(Icons.spa),
                  label: 'Classes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_outline),
                  activeIcon: Icon(Icons.bookmark),
                  label: 'Bookings'),
            ],
          )),
    );
  }

  Widget _buildError() {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const SizedBox(height: 12),
      Obx(() => Text(controller.errorMessage.value,
          style: const TextStyle(color: AppColors.textSecondary))),
      const SizedBox(height: 12),
      ElevatedButton(
          onPressed: controller.refresh,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.wellness),
          child: const Text('Retry')),
    ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 0: HOME (Overview / Dashboard)
// ══════════════════════════════════════════════════════════════════════════════
class _HomeTab extends GetView<WellnessNewController> {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(children: [
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wellness', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text('Your wellness journey at a glance.',
                      style: Theme.of(context).textTheme.bodySmall),
                ])),
            IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: Get.back),
          ]),
          const SizedBox(height: 16),

          // Credit balance card
          Obx(() => AppCard(
                child: Row(children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                        color: AppColors.wellness.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.account_balance_wallet,
                        color: AppColors.wellness, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Class Credits',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                        Text('${controller.creditsRemaining.value}',
                            style: const TextStyle(
                                color: AppColors.wellness,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const Text('credits available',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ])),
                  // Next class
                  if (controller.upcomingBookings.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Next Class',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 9)),
                          Text(
                              controller.upcomingBookings.first['date']
                                      ?.toString() ??
                                  '',
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 11)),
                        ]),
                ]),
              )),
          const SizedBox(height: 12),

          // Low credits warning
          Obx(() {
            if (controller.creditsRemaining.value > 2) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.warning_amber,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('Low credits! Buy a new pass to continue booking.',
                        style:
                            TextStyle(color: AppColors.warning, fontSize: 11))),
                GestureDetector(
                  onTap: () => controller.currentTab.value = 2,
                  child: const Text('Buy Pass',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            );
          }),

          // Quick actions
          Row(children: [
            _quickAction(Icons.spa, 'Browse\nClasses', () => controller.currentTab.value = 3),
            const SizedBox(width: 10),
            _quickAction(Icons.shopping_bag, 'Buy\nPass', () => controller.currentTab.value = 2),
            const SizedBox(width: 10),
            _quickAction(Icons.bookmark, 'My\nBookings', () => controller.currentTab.value = 4),
          ]),
          const SizedBox(height: 16),

          // Active membership
          Obx(() {
            final m = controller.membershipData.value;
            if (m == null) {
              return AppCard(
                child: Column(children: [
                  const Icon(Icons.card_membership,
                      size: 32, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  const Text('No Active Pass',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.currentTab.value = 2,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.wellness,
                        foregroundColor: Colors.white),
                    child: const Text('Get a Pass'),
                  ),
                ]),
              );
            }
            final product = m['product'] as Map<String, dynamic>? ?? {};
            return AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.card_membership,
                          size: 18, color: AppColors.wellness),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(product['name']?.toString() ?? 'Active Pass',
                              style: Theme.of(context).textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('Active',
                            style: TextStyle(
                                color: AppColors.success, fontSize: 9)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    if (m['end_date'] != null)
                      Text('Expires: ${_fmtDate(m['end_date'])}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                  ]),
            );
          }),
          const SizedBox(height: 16),

          // Upcoming bookings preview
          Obx(() {
            final upcoming = controller.upcomingBookings.take(3).toList();
            if (upcoming.isEmpty) return const SizedBox.shrink();
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Classes',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...upcoming.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(10),
                          child: Row(children: [
                            const Icon(Icons.spa,
                                size: 18, color: AppColors.wellness),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(b['className']?.toString() ?? '',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                      '${b['date'] ?? ''} • ${b['time'] ?? ''}',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10)),
                                ])),
                          ]),
                        ),
                      )),
                ]);
          }),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Icon(icon, size: 24, color: AppColors.wellness),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 11)),
          ]),
        ),
      ),
    );
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(d.toString()));
    } catch (_) {
      return d.toString();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1: MY MEMBERSHIP + Credits Ledger
// ══════════════════════════════════════════════════════════════════════════════
class _MembershipTab extends GetView<WellnessNewController> {
  const _MembershipTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final membership = controller.membershipData.value;
        final credits = controller.creditsRemaining.value;
        final ledger = controller.creditsLedger.toList();

        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('My Membership', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Your active pass, credit balance, and transaction history.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          // Credit balance
          AppCard(
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('CREDITS BALANCE',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('$credits',
                        style: const TextStyle(
                            color: AppColors.wellness,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    const Text('class credits remaining',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ])),
              CircularProgressIndicator(
                value: membership != null
                    ? _creditPercent(credits, membership)
                    : 0,
                backgroundColor: AppColors.surface,
                color: AppColors.wellness,
                strokeWidth: 8,
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Active pass
          if (membership != null) ...[
            AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    const Icon(Icons.card_membership,
                        size: 18, color: AppColors.wellness),
                    const SizedBox(width: 8),
                    const Text('Active Pass',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                            membership['status']?.toString().capitalize ??
                                'Active',
                            style: const TextStyle(
                                color: AppColors.success, fontSize: 10))),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                      membership['product']?['name']?.toString() ?? '',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  _detailRow('Type',
                      membership['product']?['type']?.toString() ?? ''),
                  _detailRow('Duration',
                      membership['product']?['duration']?.toString() ?? ''),
                  _detailRow('Start', _fmtDate(membership['start_date'])),
                  _detailRow('Expires', _fmtDate(membership['end_date'])),
                  _detailRow('Auto Renew',
                      membership['auto_renew'] == true ? 'Yes' : 'No'),
                ])),
            // Payments section
            Builder(builder: (_) {
              final payments = membership['payments'] as List? ?? [];
              if (payments.isEmpty) return const SizedBox.shrink();
              final pay = payments.first as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Payment Details',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      _detailRow('Amount', '\$${_numStr(pay['amount'])}'),
                      _detailRow(
                          'Method', pay['payment_method']?.toString() ?? ''),
                      _detailRow(
                          'Status', pay['payment_status']?.toString() ?? ''),
                      _detailRow('Date', _fmtDate(pay['payment_date'])),
                      if (pay['transaction_id'] != null)
                        _detailRow('Transaction',
                            pay['transaction_id']?.toString() ?? ''),
                    ])),
              );
            }),
            const SizedBox(height: 12),
          ] else
            AppCard(
                child: Column(children: [
              const Icon(Icons.card_membership,
                  size: 32, color: AppColors.textMuted),
              const SizedBox(height: 8),
              const Text('No active membership',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: () => controller.currentTab.value = 2,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.wellness,
                      foregroundColor: Colors.white),
                  child: const Text('Buy a Pass')),
            ])),

          // Credits Ledger
          const SizedBox(height: 16),
          Text('Credits History',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (ledger.isEmpty)
            const Text('No transactions yet.',
                style: TextStyle(color: AppColors.textSecondary))
          else
            ...ledger.map((tx) => _LedgerRow(tx: tx)),
        ]);
      }),
    );
  }

  double _creditPercent(int credits, Map<String, dynamic> m) {
    final limit = m['product']?['class_limit'];
    if (limit == null || limit == 0) return 1.0;
    return (credits / (limit as num)).clamp(0.0, 1.0);
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
        ]));
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '';
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(d.toString()));
    } catch (_) {
      return d.toString();
    }
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.tx});
  final Map<String, dynamic> tx;

  @override
  Widget build(BuildContext context) {
    final type = tx['transaction_type']?.toString() ?? '';
    final amount = tx['credits_amount'];
    final balance = tx['balance_after'];
    final notes = tx['notes']?.toString() ?? '';
    final date = tx['date']?.toString() ?? '';

    Color color;
    IconData icon;
    switch (type) {
      case 'granted':
        color = AppColors.success;
        icon = Icons.add_circle_outline;
        break;
      case 'refunded':
        color = AppColors.info;
        icon = Icons.replay;
        break;
      case 'used':
        color = AppColors.warning;
        icon = Icons.remove_circle_outline;
        break;
      default:
        color = AppColors.textMuted;
        icon = Icons.circle_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(notes.isNotEmpty ? notes : type.capitalize!,
                    maxLines: 2,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 12)),
                if (date.isNotEmpty)
                  Text(date,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
                '${amount is num && amount > 0 ? '+' : ''}$amount',
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            Text('Bal: $balance',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 9)),
          ]),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2: BUY PASSES
// ══════════════════════════════════════════════════════════════════════════════
class _BuyPassesTab extends GetView<WellnessNewController> {
  const _BuyPassesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final items = controller.products.toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('Buy a Pass', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Choose a class pass package that fits your wellness goals.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Center(
                child: Text('No passes available.',
                    style: TextStyle(color: AppColors.textSecondary)))
          else
            ...items.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PassCard(data: p),
                )),
        ]);
      }),
    );
  }
}

class _PassCard extends GetView<WellnessNewController> {
  const _PassCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? '';
    final price = data['price'];
    final perClass = data['perClass']?.toString() ?? '';
    final classes = data['classes']?.toString() ?? '';
    final validity = data['validity']?.toString() ?? '';
    final details = data['details']?.toString() ?? '';
    final isPopular = data['isPopular'] == true;
    final badge = data['badgeText']?.toString() ?? '';
    final isUnlimited = data['isUnlimited'] == true;
    final guestPasses = data['guestPasses'] as int? ?? 0;
    final billingCycle = data['billingCycle']?.toString() ?? '';
    final productId = data['id'] as int;

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Badge
        if (badge.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: isPopular
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(badge,
                style: TextStyle(
                    color: isPopular ? AppColors.primary : AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        // Name + Price
        Row(children: [
          Expanded(
              child: Text(name,
                  style: Theme.of(context).textTheme.titleSmall)),
          if (price != null)
            Text('\$${_numStr(price)}',
                style: const TextStyle(
                    color: AppColors.wellness,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        // Details row
        if (perClass.isNotEmpty) _row(Icons.attach_money, perClass),
        if (classes.isNotEmpty)
          _row(Icons.confirmation_number_outlined, classes),
        if (validity.isNotEmpty) _row(Icons.timer_outlined, 'Valid: $validity'),
        if (billingCycle.isNotEmpty)
          _row(Icons.repeat, 'Billing: $billingCycle'),
        if (isUnlimited) _row(Icons.all_inclusive, 'Unlimited Access'),
        if (guestPasses > 0)
          _row(Icons.people_outline, '$guestPasses Guest Pass(es)'),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(details,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11, height: 1.4)),
        ],
        const SizedBox(height: 12),
        // Buy button
        SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isBooking.value
                      ? null
                      : () => controller.buyPass(productId),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.wellness,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: controller.isBooking.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Buy Now'),
                ))),
      ]),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12))),
      ]));
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3: BROWSE CLASSES
// ══════════════════════════════════════════════════════════════════════════════
class _ClassesTab extends GetView<WellnessNewController> {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wellness Classes',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                    'Browse and book wellness sessions using your pass credits.',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
        ),
        // Category chips
        SizedBox(
          height: 34,
          child: Obx(() {
            final active = controller.selectedCategory.value;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cat = controller.categories[i];
                final isActive = active == cat;
                return GestureDetector(
                  onTap: () => controller.selectedCategory.value = cat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.wellness
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isActive
                                ? AppColors.wellness
                                : AppColors.border)),
                    child: Text(controller.categoryLabels[i],
                        style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11)),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        // Class list
        Expanded(
          child: Obx(() {
            final items = controller.filteredClasses;
            if (items.isEmpty) {
              return const Center(
                  child: Text('No classes found.',
                      style: TextStyle(color: AppColors.textSecondary)));
            }
            return RefreshIndicator(
              onRefresh: controller.refreshClasses,
              color: AppColors.wellness,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) =>
                    _WellnessClassCard(data: items[i]),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _WellnessClassCard extends GetView<WellnessNewController> {
  const _WellnessClassCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? '';
    final instructor = data['instructor']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';
    final time = data['timeRange']?.toString() ?? data['time']?.toString() ?? '';
    final duration = data['duration']?.toString() ?? '';
    final spotsLeft = data['spotsLeft'] as int? ?? 0;
    final maxCap = data['maxCapacity'] as int? ?? 0;
    final isFull = data['isFull'] == true || spotsLeft <= 0;
    final dropInPrice = data['drop_in_price'];
    final image = _fixImg(data['image']?.toString());
    final room = data['room']?.toString() ?? '';
    final studio = data['studio']?.toString() ?? '';
    final level = data['level']?.toString() ?? '';
    final intensity = data['intensity']?.toString() ?? '';
    final waitlistCount = data['waitlistCount'] as int? ?? 0;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: image.isNotEmpty
                ? Image.network(image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(name,
                              style:
                                  Theme.of(context).textTheme.titleSmall)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color:
                                  AppColors.wellness.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(category,
                              style: const TextStyle(
                                  color: AppColors.wellness,
                                  fontSize: 9))),
                    ]),
                    const SizedBox(height: 6),
                    _info(Icons.person_outline, instructor),
                    _info(Icons.access_time, '$time • $duration'),
                    _info(Icons.location_on_outlined,
                        [room, studio].where((s) => s.isNotEmpty).join(', ')),
                    if (level.isNotEmpty || intensity.isNotEmpty)
                      _info(Icons.bar_chart,
                          [level, intensity].where((s) => s.isNotEmpty).join(' • ')),
                    const SizedBox(height: 8),
                    // Capacity bar
                    Row(children: [
                      Expanded(
                          child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCap > 0
                              ? (maxCap - spotsLeft) / maxCap
                              : 0,
                          backgroundColor: AppColors.surface,
                          color: isFull
                              ? AppColors.error
                              : AppColors.wellness,
                          minHeight: 5,
                        ),
                      )),
                      const SizedBox(width: 8),
                      Text('${maxCap - spotsLeft}/$maxCap',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 10)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(
                          isFull
                              ? 'Full'
                              : '$spotsLeft spots left',
                          style: TextStyle(
                              color: isFull
                                  ? AppColors.error
                                  : AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                      if (waitlistCount > 0) ...[
                        const SizedBox(width: 8),
                        Text('$waitlistCount on waitlist',
                            style: const TextStyle(
                                color: AppColors.warning, fontSize: 10)),
                      ],
                      const Spacer(),
                      if (dropInPrice != null)
                        Text('Drop-in: \$${_numStr(dropInPrice)}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 10)),
                    ]),
                  ])),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
      height: 150,
      width: double.infinity,
      color: AppColors.wellness.withValues(alpha: 0.08),
      child:
          const Icon(Icons.spa, size: 40, color: AppColors.wellness));

  Widget _info(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]));

  void _showDetail(BuildContext context) {
    final desc = data['desc']?.toString() ?? '';
    final rawStart = data['rawStartDate']?.toString() ?? '';
    final classId = data['id'] as int;
    final dropInPrice = data['drop_in_price'];
    final isFull =
        data['isFull'] == true || (data['spotsLeft'] as int? ?? 0) <= 0;
    final allowedMemberships = data['allowedMemberships'] as List? ?? [];

    Get.to(() => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: Get.back),
              title: Text(data['name']?.toString() ?? '')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _fixImg(data['image']?.toString()).isNotEmpty
                  ? Image.network(_fixImg(data['image']?.toString()),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(height: 14),
            Text(data['name']?.toString() ?? '',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (desc.isNotEmpty)
              Text(desc,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(height: 1.5)),
            const SizedBox(height: 12),
            // All info
            AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _info(Icons.person_outline,
                      'Instructor: ${data['instructor'] ?? ''}'),
                  _info(Icons.access_time,
                      'Time: ${data['timeRange'] ?? data['time'] ?? ''}'),
                  _info(Icons.timer_outlined,
                      'Duration: ${data['duration'] ?? ''}'),
                  _info(Icons.location_on_outlined,
                      'Location: ${data['room'] ?? ''}, ${data['studio'] ?? ''}'),
                  _info(Icons.bar_chart,
                      'Level: ${data['level'] ?? ''} • ${data['intensity'] ?? ''}'),
                  _info(Icons.category_outlined,
                      'Category: ${data['category'] ?? ''}'),
                  _info(Icons.people,
                      'Spots: ${data['spotsLeft'] ?? 0} of ${data['maxCapacity'] ?? 0}'),
                  if (data['days_of_week'] != null)
                    _info(Icons.calendar_view_week,
                        'Days: ${data['days_of_week']}'),
                  if (data['repeat'] != null)
                    _info(Icons.repeat, 'Repeat: ${data['repeat']}'),
                ])),
            const SizedBox(height: 12),
            // Allowed passes
            if (allowedMemberships.isNotEmpty) ...[
              Text('Accepted Passes',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              ...allowedMemberships.map((m) {
                final mMap = m as Map<String, dynamic>;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                          '${mMap['name']} (${mMap['limit'] ?? mMap['price'] ?? ''})',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ]));
              }),
              const SizedBox(height: 12),
            ],
            // Book buttons
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.bookWithCredit(classId, [
                  rawStart.isNotEmpty
                      ? rawStart
                      : DateFormat('yyyy-MM-dd').format(DateTime.now())
                ]);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wellness,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text(isFull
                  ? 'Join Waitlist (1 Credit)'
                  : 'Book with Pass Credit (1 Credit)'),
            ),
            if (dropInPrice != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Get.back();
                  final price = dropInPrice is num
                      ? dropInPrice.toDouble()
                      : double.tryParse(dropInPrice.toString()) ?? 25.0;
                  controller.payDropIn(classId, [
                    rawStart.isNotEmpty
                        ? rawStart
                        : DateFormat('yyyy-MM-dd').format(DateTime.now())
                  ], price);
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text('Pay Drop-In (\$${_numStr(dropInPrice)})'),
              ),
            ],
          ]),
        ));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 4: MY BOOKINGS (Upcoming / Past / Waitlist)
// ══════════════════════════════════════════════════════════════════════════════
class _MyBookingsTab extends GetView<WellnessNewController> {
  const _MyBookingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Bookings',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Your upcoming, past, and waitlisted reservations.',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
        ),
        // Sub-tabs
        SizedBox(
            height: 34,
            child: Obx(() {
              final active = controller.bookingsSubTab.value;
              final labels = ['Upcoming', 'Past', 'Waitlist'];
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isActive = active == i;
                  return GestureDetector(
                    onTap: () => controller.bookingsSubTab.value = i,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.wellness
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isActive
                                  ? AppColors.wellness
                                  : AppColors.border)),
                      child: Text(labels[i],
                          style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 11)),
                    ),
                  );
                },
              );
            })),
        const SizedBox(height: 8),
        Expanded(
            child: Obx(() {
          List<Map<String, dynamic>> items;
          switch (controller.bookingsSubTab.value) {
            case 0:
              items = controller.upcomingBookings.toList();
              break;
            case 1:
              items = controller.pastBookings.toList();
              break;
            case 2:
              items = controller.waitlistBookings.toList();
              break;
            default:
              items = [];
          }
          if (items.isEmpty) {
            return const Center(
                child: Text('No bookings found.',
                    style: TextStyle(color: AppColors.textSecondary)));
          }
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: AppColors.wellness,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _BookingCard(
                  data: items[i],
                  isUpcoming: controller.bookingsSubTab.value == 0),
            ),
          );
        })),
      ]),
    );
  }
}

class _BookingCard extends GetView<WellnessNewController> {
  const _BookingCard({required this.data, this.isUpcoming = false});
  final Map<String, dynamic> data;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final name = data['className']?.toString() ?? '';
    final category = data['category']?.toString() ?? '';
    final instructor = data['instructor']?.toString() ?? '';
    final date = data['date']?.toString() ?? '';
    final time = data['time']?.toString() ?? '';
    final room = data['room']?.toString() ?? '';
    final studio = data['studio']?.toString() ?? '';
    final status = data['status']?.toString() ?? '';
    final isDropIn = data['is_drop_in'] == true;
    final dropAmount = data['drop_in_amount_paid'];
    final image = _fixImg(data['image']?.toString());
    final bookingId = data['id'] as int? ?? 0;
    final desc = data['desc']?.toString() ?? '';
    final spotsLeft = data['spotsLeft'];
    final maxCap = data['maxCapacity'];

    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.isNotEmpty
              ? Image.network(image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _mini())
              : _mini(),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Expanded(
                    child: Text(name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(status.capitalize!,
                        style: TextStyle(
                            color: _statusColor(status), fontSize: 9))),
              ]),
              const SizedBox(height: 4),
              if (category.isNotEmpty) _r(Icons.spa_outlined, category),
              if (instructor.isNotEmpty)
                _r(Icons.person_outline, instructor),
              if (date.isNotEmpty) _r(Icons.calendar_today_outlined, date),
              if (time.isNotEmpty) _r(Icons.access_time, time),
              if (room.isNotEmpty || studio.isNotEmpty)
                _r(Icons.location_on_outlined,
                    [room, studio].where((s) => s.isNotEmpty).join(', ')),
              if (isDropIn && dropAmount != null)
                _r(Icons.payment_outlined,
                    'Drop-in: \$${_numStr(dropAmount)}'),
              if (spotsLeft != null && maxCap != null)
                _r(Icons.people_outline, '$spotsLeft/$maxCap spots'),
              if (isUpcoming && bookingId > 0) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _confirmCancel(context, bookingId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel_outlined,
                              size: 14, color: AppColors.error),
                          SizedBox(width: 4),
                          Text('Cancel Booking',
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 11)),
                        ]),
                  ),
                ),
              ],
            ])),
      ]),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'waitlist':
      case 'waiting':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _mini() => Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: AppColors.wellness.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.spa, size: 24, color: AppColors.wellness));

  Widget _r(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11))),
      ]));

  void _confirmCancel(BuildContext context, int id) {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Cancel Booking'),
      content: const Text(
          'Cancel this reservation? 1 credit will be refunded to your balance.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: const Text('Keep')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.cancelBooking(id);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Cancel Booking'),
        ),
      ],
    ));
  }
}
