enum TransactionType { income, expense }

// Predefined expense categories
enum ExpenseCategory {
  rewardP2TL,
  food,
  transport,
  shopping,
  health,
  entertainment,
  utilities,
  education,
  others,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final ExpenseCategory? category; // Optional category for expense transactions

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.category, // Optional parameter
  });

  // Convert a Transaction object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last, // Store enum as string
      'date': date.toIso8601String(), // Store DateTime as ISO 8601 string
      'category': category
          ?.toString()
          .split('.')
          .last, // Store category as string if exists
    };
  }

  // Create a Transaction object from a Firestore Map with safer parsing and detailed logging
  factory Transaction.fromMap(Map<String, dynamic> map) {
    try {
      // Log the types of each field before parsing
      print('Transaction map data types:');
      map.forEach((key, value) {
        print('  $key: ${value.runtimeType}');
      });

      // Use null-aware operators and explicit checks for safer parsing
      final id = map['id'] as String?;
      final description = map['description'] as String?;
      final amount = (map['amount'] as num?)
          ?.toDouble(); // Handle potential null or int
      final typeString = map['type'] as String?;
      final dateString = map['date'] as String?;
      final categoryString = map['category'] as String?; // Get category string

      // Basic validation and default values if necessary
      if (id == null ||
          description == null ||
          amount == null ||
          typeString == null ||
          dateString == null) {
        // Log or handle the error appropriately. Returning null might be an option
        // if the stream can handle nulls, or throwing a specific error.
        print('Error: Missing or null field in transaction data: $map');
        throw FormatException('Missing or invalid data in transaction map.');
      }

      // Validate typeString before parsing
      if (typeString != 'income' && typeString != 'expense') {
        print('Error: Invalid type string in transaction data: $map');
        throw FormatException('Invalid transaction type string.');
      }

      final type = typeString == 'income'
          ? TransactionType.income
          : TransactionType.expense;
      final date = DateTime.parse(
        dateString,
      ); // DateTime.parse will throw if format is invalid

      // Parse category if exists
      ExpenseCategory? category;
      if (categoryString != null) {
        try {
          category = ExpenseCategory.values.firstWhere(
            (e) => e.toString().split('.').last == categoryString,
          );
        } catch (e) {
          // If category string doesn't match any enum value, default to others
          category = ExpenseCategory.others;
        }
      }

      return Transaction(
        id: id,
        description: description,
        amount: amount,
        type: type,
        date: date,
        category: category,
      );
    } catch (e) {
      // Log the error and the problematic data for debugging
      print('Error parsing transaction from Firestore: $e');
      print('Problematic data: $map');
      // Rethrow the error after logging
      rethrow;
    }
  }

  // Utility method to get category display name
  String getCategoryDisplayName() {
    if (category == null) return 'No Category';

    switch (category!) {
      case ExpenseCategory.rewardP2TL:
        return 'Reward P2TL';
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transportation';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Health & Medical';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.others:
        return 'Others';
    }
  }

  // Static method to get all expense categories with display names
  static Map<ExpenseCategory, String> getCategoryDisplayNames() {
    return {
      ExpenseCategory.rewardP2TL: 'Reward P2TL',
      ExpenseCategory.food: 'Food & Dining',
      ExpenseCategory.transport: 'Transportation',
      ExpenseCategory.shopping: 'Shopping',
      ExpenseCategory.health: 'Health & Medical',
      ExpenseCategory.entertainment: 'Entertainment',
      ExpenseCategory.utilities: 'Utilities',
      ExpenseCategory.education: 'Education',
      ExpenseCategory.others: 'Others',
    };
  }
}
