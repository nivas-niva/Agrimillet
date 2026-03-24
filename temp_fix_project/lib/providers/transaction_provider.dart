import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  Transaction? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> createPaymentOrder({
    required String cropId,
    required double quantity,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createPaymentOrder(
        cropId: cropId,
        quantity: quantity,
      );

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyPayment({
    required String transactionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTransaction = await _apiService.verifyPayment(
        transactionId: transactionId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      await fetchMyTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMyTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getMyTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchTransactionDetails(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTransaction = await _apiService.getTransaction(transactionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateDeliveryStatus({
    required String transactionId,
    String? deliveryStatus,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTransaction = await _apiService.updateDeliveryStatus(
        transactionId: transactionId,
        deliveryStatus: deliveryStatus,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      await fetchMyTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
