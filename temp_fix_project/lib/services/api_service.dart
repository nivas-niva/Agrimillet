import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/crop.dart';
import '../models/transaction.dart';
import '../models/government_price.dart';
import '../models/chat.dart';

class ApiService {
  // ─── CHANGE THIS TO YOUR PC'S LOCAL IP ADDRESS ───────────────────────────
  // Find it by running `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  // Look for IPv4 Address under your WiFi adapter, e.g. 192.168.1.5
  // Your phone and PC must be on the SAME WiFi network.
  static const String _pcIp = '192.168.0.100'; // <-- REPLACE THIS

  static const String baseUrl = 'http://localhost:5000/api';
  // ─────────────────────────────────────────────────────────────────────────

  static final ApiService _instance = ApiService._internal();
  
  String? _token;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth APIs
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String mobileNo,
    required String userType,
    required String state,
    required String district,
    BankingDetails? bankingDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'mobileNo': mobileNo,
          'userType': userType,
          'state': state,
          'district': district,
          if (bankingDetails != null) 'bankingDetails': bankingDetails.toJson(),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  Future<User> updateUserProfile({
    String? name,
    String? state,
    String? district,
    BankingDetails? bankingDetails,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _getHeaders(),
        body: jsonEncode({
          if (name != null) 'name': name,
          if (state != null) 'state': state,
          if (district != null) 'district': district,
          if (bankingDetails != null) 'bankingDetails': bankingDetails.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  // Crop APIs
  Future<Crop> uploadCrop({
    required String milletType,
    required double quantity,
    required DateTime harvestDate,
    required String market,
    required double expectedPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crops/upload'),
        headers: _getHeaders(),
        body: jsonEncode({
          'milletType': milletType,
          'quantity': quantity,
          'harvestDate': harvestDate.toIso8601String(),
          'market': market,
          'expectedPrice': expectedPrice,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Crop.fromJson(data['crop']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Upload crop failed: $e');
    }
  }

  Future<List<Crop>> getMarketplaceCrops({
    String? market,
    String? state,
    String? milletType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (market != null) 'market': market,
        if (state != null) 'state': state,
        if (milletType != null) 'milletType': milletType,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/crops/marketplace').replace(queryParameters: queryParams),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final crops = (data['crops'] as List).map((e) => Crop.fromJson(e)).toList();
        return crops;
      } else {
        throw Exception('Failed to fetch crops');
      }
    } catch (e) {
      throw Exception('Get crops failed: $e');
    }
  }

  Future<Crop> getCropDetails(String cropId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crops/$cropId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Crop.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch crop');
      }
    } catch (e) {
      throw Exception('Get crop failed: $e');
    }
  }

  Future<List<Crop>> getMyCrops() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crops/my-crops'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => Crop.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch crops');
      }
    } catch (e) {
      throw Exception('Get my crops failed: $e');
    }
  }

  Future<void> removeCrop(String cropId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/crops/$cropId'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Remove crop failed: $e');
    }
  }

  Future<GovernmentPrice> getGovernmentPrice({
    required String milletType,
    required String state,
  }) async {
    try {
      final queryParams = {
        'milletType': milletType,
        'state': state,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/crops/price/government').replace(queryParameters: queryParams),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return GovernmentPrice.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Price not found');
      }
    } catch (e) {
      throw Exception('Get government price failed: $e');
    }
  }

  Future<List<Crop>> searchCrops({
    required String query,
    String? market,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
        if (market != null) 'market': market,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/crops/search').replace(queryParameters: queryParams),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final crops = (data['crops'] as List).map((e) => Crop.fromJson(e)).toList();
        return crops;
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Search crops failed: $e');
    }
  }

  // Transaction APIs
  Future<Map<String, dynamic>> createPaymentOrder({
    required String cropId,
    required double quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/create-order'),
        headers: _getHeaders(),
        body: jsonEncode({
          'cropId': cropId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Create order failed: $e');
    }
  }

  Future<Transaction> verifyPayment({
    required String transactionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/verify-payment'),
        headers: _getHeaders(),
        body: jsonEncode({
          'transactionId': transactionId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Transaction.fromJson(data['transaction']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Verify payment failed: $e');
    }
  }

  Future<Transaction> getTransaction(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch transaction');
      }
    } catch (e) {
      throw Exception('Get transaction failed: $e');
    }
  }

  Future<List<Transaction>> getMyTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/my-transactions'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => Transaction.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      throw Exception('Get transactions failed: $e');
    }
  }

  Future<Transaction> updateDeliveryStatus({
    required String transactionId,
    String? deliveryStatus,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/delivery-status'),
        headers: _getHeaders(),
        body: jsonEncode({
          'transactionId': transactionId,
          if (deliveryStatus != null) 'deliveryStatus': deliveryStatus,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (address != null) 'address': address,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Transaction.fromJson(data['transaction']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Update delivery failed: $e');
    }
  }

  // Chat APIs
  Future<Chat> sendChatMessage({
    required String message,
    String language = 'en',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/message'),
        headers: _getHeaders(),
        body: jsonEncode({
          'message': message,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Chat.fromJson(data['chat']);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Send message failed: $e');
    }
  }

  Future<Chat> getChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/history'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Chat.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch chat history');
      }
    } catch (e) {
      throw Exception('Get chat failed: $e');
    }
  }
}
