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

  // Convert a Transaction object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.toString().split('.').last, // Store enum as string
      'date': date.toIso8601String(), // Store DateTime as ISO 8601 string
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
      final amount = (map['amount'] as num?)?.toDouble(); // Handle potential null or int
      final typeString = map['type'] as String?;
      final dateString = map['date'] as String?;

      // Basic validation and default values if necessary
      if (id == null || description == null || amount == null || typeString == null || dateString == null) {
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

      final type = typeString == 'income' ? TransactionType.income : TransactionType.expense;
      final date = DateTime.parse(dateString); // DateTime.parse will throw if format is invalid

      return Transaction(
        id: id,
        description: description,
        amount: amount,
        type: type,
        date: date,
      );
    } catch (e) {
      // Log the error and the problematic data for debugging
      print('Error parsing transaction from Firestore: $e');
      print('Problematic data: $map');
      // Rethrow the error after logging
      rethrow; 
    }
  }
}