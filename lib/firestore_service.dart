// lib/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _transactionsCol {
    if (_uid == null) {
      throw Exception('User not logged in');
    }
    return _db.collection('users').doc(_uid).collection('transactions');
  }

  /// Add new income or expense
  Future<void> addTransaction({
    required String type, // 'income' or 'expense'
    required double amount,
    required String category,
    String? note,
    required DateTime date,
  }) async {
    await _transactionsCol.add({
      'type': type,
      'amount': amount,
      'category': category,
      'note': note ?? '',
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete transaction by document ID
  Future<void> deleteTransaction(String id) async {
    await _transactionsCol.doc(id).delete();
  }

  /// Stream of all transactions ordered by date (latest first)
  Stream<QuerySnapshot<Map<String, dynamic>>> transactionsStream() {
    return _transactionsCol.orderBy('date', descending: true).snapshots();
  }
}
