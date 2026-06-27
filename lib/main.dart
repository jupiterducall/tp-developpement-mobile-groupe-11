import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'viewmodels/ville_viewmodel.dart';
import 'screens/ecran_acceuil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Exercice C : Planifier une notification quotidienne
  // Note: Pour un TP, periodicallyShow avec RepeatInterval.daily déclenchera 
  // la notification toutes les 24h à partir de maintenant.
  await flutterLocalNotificationsPlugin.periodicallyShow(
    0,
    'Météo du jour',
    'N\'oubliez pas de consulter la météo ce matin !',
    RepeatInterval.daily,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_meteo',
        'Météo Quotidienne',
        importance: Importance.low,
        priority: Priority.low,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => VilleViewModel(),
      child: MaterialApp(
        title: 'AppMeteo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const EcranAccueil(),
      ),
    ),
  );
}
