import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  String _selectedLanguage = 'en';
  bool _isPlaying = false;
  bool _isListening = false;
  String _assistantMessage =
      'Hello! I\'m your AgriMillet assistant. How can I help you today?';
  String _userInput = '';

  // ─── Language → TTS locale ───────────────────────────────────────────────
  final Map<String, String> _ttsLocales = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'kn': 'kn-IN',
    'mr': 'mr-IN',
    'gu': 'gu-IN',
  };

  // ─── Language → STT locale ───────────────────────────────────────────────
  final Map<String, String> _sttLocales = {
    'en': 'en_US',
    'hi': 'hi_IN',
    'ta': 'ta_IN',
    'te': 'te_IN',
    'kn': 'kn_IN',
    'mr': 'mr_IN',
    'gu': 'gu_IN',
  };

  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
  };

  // ─── Keyword maps per language (used for mic matching) ───────────────────
  // Each language lists keywords that map to topic keys.
  final Map<String, Map<String, String>> _keywordToTopic = {
    'en': {
      'price': 'prices', 'prices': 'prices', 'cost': 'prices', 'rate': 'prices',
      'crop': 'crops',  'crops': 'crops',  'upload': 'crops',
      'pay': 'payment', 'payment': 'payment', 'money': 'payment',
      'deliver': 'delivery', 'delivery': 'delivery', 'shipping': 'delivery',
      'help': 'help',
    },
    'hi': {
      'कीमत': 'prices', 'मूल्य': 'prices', 'दाम': 'prices',
      'फसल': 'crops',  'अपलोड': 'crops',
      'भुगतान': 'payment', 'पैसे': 'payment',
      'डिलीवरी': 'delivery', 'पहुंचाना': 'delivery',
      'मदद': 'help',
    },
    'ta': {
      'விலை': 'prices',
      'பயிர்': 'crops',  'பதிவேற்ற': 'crops',
      'பணம்': 'payment',
      'டெலிவரி': 'delivery',
      'உதவி': 'help',
    },
    'te': {
      'ధర': 'prices',
      'పంట': 'crops',  'అప్‌లోడ్': 'crops',
      'చెల్లింపు': 'payment', 'డబ్బు': 'payment',
      'డెలివరీ': 'delivery',
      'సహాయం': 'help',
    },
    'kn': {
      'ಬೆಲೆ': 'prices',
      'ಬೆಳೆ': 'crops',  'ಅಪ್‌ಲೋಡ್': 'crops',
      'ಪಾವತಿ': 'payment',
      'ವಿತರಣೆ': 'delivery',
      'ಸಹಾಯ': 'help',
    },
    'mr': {
      'किंमत': 'prices',
      'पीक': 'crops',  'अपलोड': 'crops',
      'पेमेंट': 'payment', 'पैसे': 'payment',
      'डिलीव्हरी': 'delivery',
      'मदत': 'help',
    },
    'gu': {
      'કિંમત': 'prices',
      'પાક': 'crops',  'અપલોડ': 'crops',
      'ચૂકવણી': 'payment',
      'ડિલીવરી': 'delivery',
      'મદદ': 'help',
    },
  };

  final Map<String, Map<String, String>> _responses = {
    'en': {
      'hi': 'Hello! I\'m your AgriMillet assistant.',
      'help': 'I can help you with crop prices, farming tips, market information, and payment assistance.',
      'prices': 'You can check government-fixed prices for different millet types in the crop details section.',
      'crops': 'You can upload crops by clicking the upload button on your home screen.',
      'payment': 'Payments are processed securely through Razorpay. Your money goes directly to farmer accounts.',
      'delivery': 'Farmers provide GPS-tracked delivery. You can track your order in real-time.',
    },
    'hi': {
      'hi': 'नमस्ते! मैं आपका एग्रीमिलेट सहायक हूँ।',
      'help': 'मैं आपको फसल की कीमतें, खेती की सुझावें, बाजार की जानकारी देने में मदद कर सकता हूँ।',
      'prices': 'आप फसल विवरण अनुभाग में विभिन्न बाजरा प्रकारों के लिए सरकार द्वारा निर्धारित कीमतें देख सकते हैं।',
      'crops': 'आप अपनी होम स्क्रीन पर अपलोड बटन पर क्लिक करके फसलें अपलोड कर सकते हैं।',
      'payment': 'भुगतान Razorpay के माध्यम से सुरक्षित रूप से संसाधित होता है।',
      'delivery': 'किसान जीपीएस-ट्रैक की गई डिलीवरी प्रदान करते हैं।',
    },
    'ta': {
      'hi': 'வணக்கம்! நான் உங்கள் AgriMillet உதவியாளர்.',
      'help': 'விளைபொருட்களின் விலை, விவசாய குறிப்புகள், சந்தை தகவல் ஆகியவற்றில் நான் உங்களுக்கு உதவ முடியும்.',
      'prices': 'விளைபொருளின் விவரங்கள் பிரிவில் பல்வேறு கேழ்வரகு வகைகளுக்கான அரசு நிர்ధரித விலைகளை பார்க்கலாம்.',
      'crops': 'உங்கள் முகப்பு திரையில் பதிவேற்ற பொத்தானைக் கிளிக் செய்து பயிர்களை பதிவேற்றலாம்.',
      'payment': 'Razorpay மூலம் பாதுகாப்பாக பணம் செலுத்தப்படுகிறது.',
      'delivery': 'விவசாயிகள் GPS-ல் பயணம் செய்யும் டெலிவரி வழங்குகின்றனர்.',
    },
    'te': {
      'hi': 'నమస్కారం! నేను మీ AgriMillet సహాయకుడిని.',
      'help': 'నేను పంట ధరలు, వ్యవసాయ చిట్కాలు, మార్కెట్ సమాచారం గురించి మీకు సహాయం చేయగలను.',
      'prices': 'పంట వివరాల విభాగంలో వివిధ బజ్రా రకాల కోసం ప్రభుత్వ నిర్ధారిత ధరలను చూడవచ్చు.',
      'crops': 'మీ హోమ్ స్క్రీన్‌లో అప్‌లోడ్ బటన్‌ను క్లిక్ చేయడం ద్వారా పంటలను అప్‌లోడ్ చేయవచ్చు.',
      'payment': 'Razorpay ద్వారా నిరాపద్గా చెల్లింపులు సంసాధనం చేయబడతాయి.',
      'delivery': 'రైతులు GPS-ట్రాక్ చేసిన డెలివరీని అందిస్తారు.',
    },
    'kn': {
      'hi': 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ AgriMillet ಸಹಾಯಕ.',
      'help': 'ನಾನು ಬೆಳೆ ಬೆಲೆಗಳು, ಕೃಷಿ ಸಲಹೆಗಳು, ಮಾರುಕಟ್ಟೆ ಮಾಹಿತಿ ಮೂಲಕ ನಿಮಗೆ ಸಹಾಯ ಮಾಡಬಹುದು.',
      'prices': 'ಬೆಳೆ ವಿವರಣೆ ವಿಭಾಗದಲ್ಲಿ ವಿವಿಧ ಸಾಮೆ ಬಗೆಗಳ ಸರ್ಕಾರ-ನಿರ್ಧರಿತ ಬೆಲೆಗಳನ್ನು ನೋಡಬಹುದು.',
      'crops': 'ನಿಮ್ಮ ಹೋಮ್ ಸ್ಕ್ರೀನ್‌ನಲ್ಲಿ ಅಪ್‌ಲೋಡ್ ಬಟನ್ ಕ್ಲಿಕ್ ಮಾಡಿ ಬೆಳೆಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಬಹುದು.',
      'payment': 'Razorpay ಮೂಲಕ ಸುರಕ್ಷಿತವಾಗಿ ಪಾವತಿ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತದೆ.',
      'delivery': 'ರೈತರು GPS-ಟ್ರ್ಯಾಕ್ ಮಾಡಿದ ವಿತರಣೆಯನ್ನು ಒದಗಿಸುತ್ತಾರೆ.',
    },
    'mr': {
      'hi': 'नमस्कार! मी तुमचा AgriMillet सहायक आहे.',
      'help': 'मी तुम्हाला पिक किंमती, शेती सुझाव, बाजार माहिती मदत करू शकतो.',
      'prices': 'शेती तपशील विभागात विविध ज्वारी प्रकारांच्या सरकार-निर्धारित किंमती पहा.',
      'crops': 'तुमच्या होम स्क्रीनवर अपलोड बटन क्लिक करून पिके अपलोड करा.',
      'payment': 'Razorpay द्वारे सुरक्षितपणे पेमेंट प्रक्रिया केली जाते.',
      'delivery': 'शेतकरी GPS-ट्रॅक केलेली डिलीव्हरी प्रदान करतात.',
    },
    'gu': {
      'hi': 'નમસ્તે! હું તમારો AgriMillet સહાયક છું.',
      'help': 'હું તમને પાક કિંમતો, ખેતી ટિપ્સ, બજાર માહિતી સાથે મદદ કરી શકું છું.',
      'prices': 'પાક વિગતો વિભાગમાં વિવિધ જ્વારીર પ્રકારોની સરકાર દ્વારા નિર્ધારિત કિંમતો જુઓ.',
      'crops': 'તમારી હોમ સ્ક્રીન પર અપલોડ બટન ક્લિક કરીને પાક અપલોડ કરો.',
      'payment': 'Razorpay દ્વારા સુરક્ષિત રીતે ચુકવણી પ્રક્રિયા કરવામાં આવે છે.',
      'delivery': 'ખેડૂતો GPS-ટ્રૅક કરેલી ડિલીવરી આપે છે.',
    },
  };

  // ─── Fallback "I didn't understand" messages per language ─────────────────
  final Map<String, String> _fallbackMessages = {
    'en': 'Sorry, I didn\'t understand. Try saying: prices, crops, payment, or delivery.',
    'hi': 'माफ करें, मैं समझ नहीं पाया। कहने की कोशिश करें: कीमत, फसल, भुगतान, या डिलीवरी।',
    'ta': 'மன்னிக்கவும், புரியவில்லை. முயற்சிக்கவும்: விலை, பயிர், பணம், அல்லது டெலிவரி.',
    'te': 'క్షమించండి, అర్థం కాలేదు. ప్రయత్నించండి: ధర, పంట, చెల్లింపు, లేదా డెలివరీ.',
    'kn': 'ಕ್ಷಮಿಸಿ, ಅರ್ಥವಾಗಲಿಲ್ಲ. ಪ್ರಯತ್ನಿಸಿ: ಬೆಲೆ, ಬೆಳೆ, ಪಾವತಿ, ಅಥವಾ ವಿತರಣೆ.',
    'mr': 'माफ करा, समजले नाही. प्रयत्न करा: किंमत, पीक, पेमेंट, किंवा डिलीव्हरी.',
    'gu': 'માફ કરો, સમજાયું નહીં. પ્રયાસ કરો: કિંમત, પાક, ચૂકવણી, અથવા ડિલીવરી.',
  };

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeechToText();
    _speak(_assistantMessage);
  }

  // ─── FIX 1: TTS now uses the correct locale for the selected language ─────
  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_ttsLocales[_selectedLanguage] ?? 'en-US');
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    });
  }

  Future<void> _initSpeechToText() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
      if (!available) debugPrint('Speech recognition not available');
    } catch (e) {
      debugPrint('Error initializing STT: $e');
    }
  }

  // ─── FIX 2: _speak() now always uses the currently selected language ──────
  Future<void> _speak(String text) async {
    setState(() => _isPlaying = true);
    final locale = _ttsLocales[_selectedLanguage] ?? 'en-US';
    try {
      await _flutterTts.setLanguage(locale);
      await Future.delayed(const Duration(milliseconds: 200));
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
      setState(() => _isPlaying = false);
    }
  }

  // ─── FIX 3: Mic uses the selected language locale for recognition ─────────
  Future<void> _startListening() async {
    if (_isListening) return;
    bool available = await _speechToText.initialize();
    if (!available) return;

    final localeId = _sttLocales[_selectedLanguage] ?? 'en_US';
    setState(() {
      _isListening = true;
      _userInput = '';
    });

    _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        setState(() => _userInput = result.recognizedWords);
      },
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    setState(() => _isListening = false);
    if (_userInput.isNotEmpty) _handleUserInput(_userInput);
  }

  // ─── FIX 4: Mic input now matches keywords and returns a proper response ───
  void _handleUserInput(String input) {
    final lowerInput = input.toLowerCase();
    final keywords = _keywordToTopic[_selectedLanguage] ?? _keywordToTopic['en']!;

    String? matchedTopic;
    for (final entry in keywords.entries) {
      if (lowerInput.contains(entry.key.toLowerCase())) {
        matchedTopic = entry.value;
        break;
      }
    }

    final message = matchedTopic != null
        ? (_responses[_selectedLanguage]?[matchedTopic] ??
            _responses['en']?[matchedTopic] ??
            _fallbackMessages[_selectedLanguage] ??
            _fallbackMessages['en']!)
        : (_fallbackMessages[_selectedLanguage] ?? _fallbackMessages['en']!);

    setState(() => _assistantMessage = message);
    _speak(message);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  void _selectTopic(String topic) {
    final message = _responses[_selectedLanguage]?[topic] ??
        _responses['en']?[topic] ??
        'Information not available';
    setState(() => _assistantMessage = message);
    _speak(message);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Assistant Avatar ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.mic : Icons.smart_toy,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AgriMillet Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPlaying ? 'Speaking...' : 'Ready to help',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ── Message Display ───────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assistant Message',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _assistantMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Speech Input ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ask Me Something',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userInput.isEmpty
                        ? 'Hold the microphone to speak...'
                        : _userInput,
                    style: TextStyle(
                      fontSize: 14,
                      color: _userInput.isEmpty
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF333333),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onLongPress: _startListening,
                      onLongPressEnd: (_) => _stopListening(),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.red
                              : const Color(0xFF2E7D32),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening
                                      ? Colors.red
                                      : const Color(0xFF2E7D32))
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  if (_isListening)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          'Listening...',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Language Selector ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _languageNames.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() => _selectedLanguage = value);

                        // ── FIX 5: Language change uses _speak() correctly ──
                        final confirmMessages = {
                          'en': 'Language changed to English',
                          'hi': 'भाषा हिंदी में बदल गई है',
                          'ta': 'மொழி தமிழுக்கு மாற்றப்பட்டது',
                          'te': 'భాష తెలుగులో మార్చబడింది',
                          'kn': 'ಭಾಷೆ ಕನ್ನಡಕ್ಕೆ ಬದಲಾಗಿದೆ',
                          'mr': 'भाषा मराठीत बदलली आहे',
                          'gu': 'ભાષા ગુજરાતીમાં બદલાઈ ગઈ છે',
                        };
                        final message =
                            confirmMessages[value] ?? 'Language changed';
                        setState(() => _assistantMessage = message);
                        // _speak reads _selectedLanguage which is already updated
                        await _speak(message);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Control Buttons ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isPlaying ? _stopSpeaking : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stop, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isPlaying ? 'Stop' : 'Stopped',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _speak(_assistantMessage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volume_up, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Replay',
                              style:
                                  TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Quick Topics ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Topics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildTopicButton('💰 Prices', 'prices'),
                      _buildTopicButton('🌾 Crops', 'crops'),
                      _buildTopicButton('💳 Payment', 'payment'),
                      _buildTopicButton('🚚 Delivery', 'delivery'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicButton(String label, String topic) {
    return ElevatedButton(
      onPressed: () => _selectTopic(topic),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF0F7ED),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFDCEDD6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }
}
