import 'package:catalyst/core/constants/app_colors.dart';
import 'package:catalyst/core/widgets/app_card.dart';
import 'package:catalyst/data/models/billing_model.dart';
import 'package:catalyst/modules/payments/controllers/payments_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentsView extends GetView<PaymentsController> {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        title: const Text('Payments & Billing'),
      ),
      body: Obx(() {
        // Receipt detail view
        if (controller.selectedTransaction.value != null) {
          return _ReceiptView(
              txn: controller.selectedTransaction.value!);
        }
        if (controller.isInitialLoading.value) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.transactions.isEmpty) {
          return _ErrorView();
        }
        return _BillingContent();
      }),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends GetView<PaymentsController> {
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
            Obx(() => Text(controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.fetchBilling(initial: true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Billing Content ──────────────────────────────────────────────────────
class _BillingContent extends GetView<PaymentsController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.fetchBilling,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text('Billing Overview',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('View your payment history and transaction details.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          // ── Summary Cards ──────────────────────────────
          Obx(() => _SummaryCards(summary: controller.summary.value)),
          const SizedBox(height: 20),
          // ── Category Tabs ──────────────────────────────
          _CategoryTabs(),
          const SizedBox(height: 12),
          // ── Search ─────────────────────────────────────
          _SearchField(),
          const SizedBox(height: 16),
          // ── Transactions ───────────────────────────────
          Obx(() {
            final txns = controller.transactions.toList();
            if (controller.isFetching.value && txns.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)),
              );
            }
            if (txns.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No transactions found.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transactions (${txns.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...txns.map((txn) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransactionCard(txn: txn),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});
  final BillingSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Spent',
            value: summary.totalSpent,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.receipt_long_outlined,
            label: 'Transactions',
            value: '${summary.totalTransactions}',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.card_membership_outlined,
            label: 'Active Passes',
            value: '${summary.activePassesCount}',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Category Tabs ─────────────────────────────────────────────────────────────
class _CategoryTabs extends GetView<PaymentsController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = controller.categories[i];
              final label = controller.categoryLabels[i];
              final isActive = controller.selectedCategory.value == cat;
              return GestureDetector(
                onTap: () => controller.setCategory(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          )
    );
  }
}

// ── Search Field ──────────────────────────────────────────────────────────────
class _SearchField extends GetView<PaymentsController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearch,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Transaction Card ──────────────────────────────────────────────────────────
class _TransactionCard extends GetView<PaymentsController> {
  const _TransactionCard({required this.txn});
  final BillingTransaction txn;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(String category) {
    if (category.contains('Regular')) return Icons.school_outlined;
    if (category.contains('Choreography')) return Icons.music_note_outlined;
    if (category.contains('Private')) return Icons.person_outlined;
    if (category.contains('Wellness')) return Icons.spa_outlined;
    if (category.contains('Routine')) return Icons.repeat_outlined;
    return Icons.payment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(txn.status);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_categoryIcon(txn.category),
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.description,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (txn.studentName.isNotEmpty)
                      Text(txn.studentName,
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    txn.formattedAmount.isNotEmpty
                        ? txn.formattedAmount
                        : '\$${txn.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(txn.status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _infoChip(Icons.category_outlined, txn.category),

                      if (txn.date.isNotEmpty)
                        _infoChip(Icons.calendar_today_outlined, txn.date),

                      if (txn.time.isNotEmpty)
                        _infoChip(Icons.access_time_outlined, txn.time),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => controller.viewReceipt(txn),
                child: Text(
                  'View Receipt',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text(
              text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Receipt View ──────────────────────────────────────────────────────────────
class _ReceiptView extends GetView<PaymentsController> {
  const _ReceiptView({required this.txn});
  final BillingTransaction txn;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: controller.closeReceipt,
            icon: const Icon(Icons.arrow_back, size: 16,
                color: AppColors.primary),
            label: const Text('Back to Transactions',
                style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 12),
        // Receipt card
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Receipt',
                            style:
                                Theme.of(context).textTheme.titleLarge),
                        Text(txn.transactionId,
                            style:
                                Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(txn.status,
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              // Details
              _ReceiptRow(label: 'Description', value: txn.description),
              _ReceiptRow(label: 'Category', value: txn.category),
              _ReceiptRow(label: 'Student', value: txn.studentName),
              _ReceiptRow(label: 'Date', value: txn.date),
              _ReceiptRow(label: 'Time', value: txn.time),
              _ReceiptRow(label: 'Payment Method', value: txn.method),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount Paid',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text(
                    txn.formattedAmount.isNotEmpty
                        ? txn.formattedAmount
                        : '\$${txn.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
