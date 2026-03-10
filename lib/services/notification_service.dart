import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {

    // Inicializa banco de timezones
    tz.initializeTimeZones();

    // Define timezone local
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // 🔔 Permissão Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime data,
  }) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'docdigital_vencimentos',
      'Vencimentos de documentos',
      channelDescription: 'Alertas de vencimento de documentos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      titulo,
      corpo,
      tz.TZDateTime.from(data, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }
}