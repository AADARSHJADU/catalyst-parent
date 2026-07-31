/// Summary KPI data from billing API.
class BillingSummary {
  const BillingSummary({
    this.totalSpent = '\$0.00',
    this.totalTransactions = 0,
    this.activePassesCount = 0,
    this.latestTransactionDate = '',
    this.currency = 'USD',
  });

  final String totalSpent;
  final int totalTransactions;
  final int activePassesCount;
  final String latestTransactionDate;
  final String currency;

  factory BillingSummary.fromJson(Map<String, dynamic> json) {
    return BillingSummary(
      totalSpent: json['totalSpent'] as String? ?? '\$0.00',
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      activePassesCount: json['activePassesCount'] as int? ?? 0,
      latestTransactionDate:
          json['latestTransactionDate'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

/// Single transaction from the billing API.
class BillingTransaction {
  const BillingTransaction({
    required this.id,
    this.dbId,
    required this.category,
    this.categoryType = '',
    required this.description,
    this.studentName = '',
    required this.amount,
    this.formattedAmount = '',
    this.method = '',
    this.status = 'Paid',
    this.transactionId = '',
    this.rawDate,
    this.date = '',
    this.time = '',
  });

  final String id;
  final int? dbId;
  final String category;
  final String categoryType;
  final String description;
  final String studentName;
  final double amount;
  final String formattedAmount;
  final String method;
  final String status;
  final String transactionId;
  final String? rawDate;
  final String date;
  final String time;

  factory BillingTransaction.fromJson(Map<String, dynamic> json) {
    return BillingTransaction(
      id: json['id']?.toString() ?? '',
      dbId: json['dbId'] as int?,
      category: json['category'] as String? ?? '',
      categoryType: json['categoryType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      formattedAmount: json['formattedAmount'] as String? ?? '',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? 'Paid',
      transactionId: json['transactionId'] as String? ?? '',
      rawDate: json['rawDate'] as String?,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }
}

/// Full billing response wrapper.
class BillingResponse {
  const BillingResponse({
    required this.summary,
    required this.transactions,
  });

  final BillingSummary summary;
  final List<BillingTransaction> transactions;

  factory BillingResponse.fromJson(Map<String, dynamic> json) {
    final summaryJson =
        json['summary'] as Map<String, dynamic>? ?? {};
    final txnList = json['transactions'] as List<dynamic>? ?? [];
    return BillingResponse(
      summary: BillingSummary.fromJson(summaryJson),
      transactions: txnList
          .map((e) =>
              BillingTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
