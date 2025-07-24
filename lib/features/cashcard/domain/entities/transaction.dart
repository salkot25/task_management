enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });
}
