import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/common/home_screen.dart';
import 'screens/farmer/upload_crop_screen.dart';
import 'screens/common/crop_details_screen.dart';
import 'screens/buyer/payment_screen.dart';
import 'screens/common/tracking_screen.dart';
import 'screens/common/chat_screen.dart';
import 'screens/common/profile_screen.dart';
import 'screens/common/transaction_history_screen.dart';
import 'screens/common/voice_assistant_screen.dart';
import 'utils/ui_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'AgriMillet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textPrimary,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: AppColors.textSecondary,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/upload-crop': (context) => const UploadCropScreen(),
          '/crop-details': (context) {
            final cropId = ModalRoute.of(context)?.settings.arguments as String?;
            return CropDetailsScreen(cropId: cropId ?? '');
          },
          '/payment': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return PaymentScreen(
              cropId: args?['cropId'] ?? '',
              farmerName: args?['farmerName'] ?? '',
              quantity: args?['quantity'] ?? 0,
              price: args?['price'] ?? 0.0,
              milletType: args?['milletType'] ?? '',
            );
          },
          '/tracking': (context) {
            final transactionId = ModalRoute.of(context)?.settings.arguments as String?;
            return TrackingScreen(transactionId: transactionId ?? '');
          },
          '/chat': (context) => const ChatScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/transaction-history': (context) => const TransactionHistoryScreen(),
          '/voice-assistant': (context) => const VoiceAssistantScreen(),
        },
      ),
    );
  }
}
