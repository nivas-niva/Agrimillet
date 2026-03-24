import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Chat? _chat;
  bool _isLoading = false;
  String? _error;
  String _selectedLanguage = 'en';

  Chat? get chat => _chat;
  List<ChatMessage> get messages => _chat?.messages ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedLanguage => _selectedLanguage;

  Future<void> sendMessage(String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chat = await _apiService.sendChatMessage(
        message: message,
        language: _selectedLanguage,
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

  Future<void> fetchChatHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chat = await _apiService.getChatHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
