import 'package:flutter/foundation.dart';
import '../models/crop.dart';
import '../models/government_price.dart';
import '../services/api_service.dart';

class CropProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Crop> _crops = [];
  List<Crop> _myCrops = [];
  Crop? _selectedCrop;
  GovernmentPrice? _governmentPrice;
  bool _isLoading = false;
  String? _error;

  List<Crop> get crops => _crops;
  List<Crop> get myCrops => _myCrops;
  Crop? get selectedCrop => _selectedCrop;
  GovernmentPrice? get governmentPrice => _governmentPrice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> uploadCrop({
    required String milletType,
    required double quantity,
    required DateTime harvestDate,
    required String market,
    required double expectedPrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.uploadCrop(
        milletType: milletType,
        quantity: quantity,
        harvestDate: harvestDate,
        market: market,
        expectedPrice: expectedPrice,
      );

      await fetchMyCrops();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMarketplaceCrops({
    String? market,
    String? state,
    String? milletType,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _crops = await _apiService.getMarketplaceCrops(
        market: market,
        state: state,
        milletType: milletType,
        page: page,
        limit: limit,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMyCrops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myCrops = await _apiService.getMyCrops();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchCropDetails(String cropId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCrop = await _apiService.getCropDetails(cropId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeCrop(String cropId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.removeCrop(cropId);
      await fetchMyCrops();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchGovernmentPrice({
    required String milletType,
    required String state,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _governmentPrice = await _apiService.getGovernmentPrice(
        milletType: milletType,
        state: state,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchCrops({
    required String query,
    String? market,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _crops = await _apiService.searchCrops(
        query: query,
        market: market,
        page: page,
        limit: limit,
      );

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
