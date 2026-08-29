import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP');
  final storage = await StorageService.load();
  await PurchaseService.init(storage);

  final notifications = NotificationService();
  await notifications.init();
  await notifications.scheduleDailyReminder();

  runApp(AstroQuestApp(storage: storage));
}

class AstroQuestApp extends StatelessWidget {
  const AstroQuestApp({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroQuest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: storage.onboardingDone
          ? HomeScreen(storage: storage)
          : OnboardingScreen(storage: storage),
    );
  }
}
