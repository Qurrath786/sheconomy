// lib/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // 'income' or 'expense'
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawDate = data['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String)
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    else
      parsedDate = DateTime.now();

    return TransactionModel(
      id: doc.id,
      type: data['type'] as String? ?? 'expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Other',
      note: data['note'] as String? ?? '',
      date: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      // store as Firestore Timestamp
      'date': Timestamp.fromDate(date),
    };
  }
}
