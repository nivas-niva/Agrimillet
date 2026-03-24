import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      if (_token != null) {
        _apiService.setToken(_token!);
        await _fetchUserProfile();
      }
    } catch (e) {
      _error = 'Failed to load stored token';
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String mobileNo,
    required String userType,
    required String state,
    required String district,
    BankingDetails? bankingDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        mobileNo: mobileNo,
        userType: userType,
        state: state,
        district: district,
        bankingDetails: bankingDetails,
      );

      _token = response['token'];
      _user = User.fromJson(response['user']);
      _apiService.setToken(_token!);

      // Save token to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      _token = response['token'];
      _user = User.fromJson(response['user']);
      _apiService.setToken(_token!);

      // Save token to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      _user = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? state,
    String? district,
    BankingDetails? bankingDetails,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.updateUserProfile(
        name: name,
        state: state,
        district: district,
        bankingDetails: bankingDetails,
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

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _token = null;
      _user = null;
      _apiService.clearToken();

      // Clear token from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

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
