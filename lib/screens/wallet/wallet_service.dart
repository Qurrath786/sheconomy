import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../transaction_model.dart';

class WalletService {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  WalletService({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : db = firestore ?? FirebaseFirestore.instance,
      auth = firebaseAuth ?? FirebaseAuth.instance;

  String? get _uid => auth.currentUser?.uid;

  /// Stream of transactions -> List<TransactionModel>
  Stream<List<TransactionModel>> transactionsStream() {
    if (_uid == null) return const Stream.empty();

    return db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromDoc(doc);
          }).toList();
        });
  }

  /// Add new transaction
  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    String? note,
    required DateTime date,
  }) async {
    if (_uid == null) throw Exception("Not logged in");

    final ref = db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc();

    final transaction = TransactionModel(
      id: ref.id,
      type: type,
      amount: amount,
      category: category,
      note: note ?? "",
      date: date,
    );

    await ref.set(transaction.toJson());
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    if (_uid == null) throw Exception("Not logged in");

    await db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }
}
