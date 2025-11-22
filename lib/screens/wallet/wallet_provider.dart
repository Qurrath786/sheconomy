// lib/screens/wallet/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_service.dart';
import '../../transaction_model.dart';

final walletServiceProvider = Provider<WalletService>((ref) => WalletService());

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
      final svc = ref.watch(walletServiceProvider);
      return svc.transactionsStream();
    });

class WalletTotals {
  final double totalIncome;
  final double totalExpense;
  final double thisMonthExpense;

  WalletTotals({
    required this.totalIncome,
    required this.totalExpense,
    required this.thisMonthExpense,
  });

  double get balance => totalIncome - totalExpense;

  factory WalletTotals.empty() =>
      WalletTotals(totalIncome: 0, totalExpense: 0, thisMonthExpense: 0);
}

final walletTotalsProvider = Provider.autoDispose<WalletTotals>((ref) {
  final txsAsync = ref.watch(transactionsStreamProvider);
  return txsAsync.when(
    data: (txs) {
      double income = 0, expense = 0, thisMonthExpense = 0;
      final now = DateTime.now();
      for (final t in txs) {
        if (t.type == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
          if (t.date.year == now.year && t.date.month == now.month) {
            thisMonthExpense += t.amount;
          }
        }
      }
      return WalletTotals(
        totalIncome: income,
        totalExpense: expense,
        thisMonthExpense: thisMonthExpense,
      );
    },
    loading: () => WalletTotals.empty(),
    error: (_, __) => WalletTotals.empty(),
  );
});
