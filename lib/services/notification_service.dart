import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> mostrarNotificacaoAgora({
    required String titulo,
    required String corpo,
  }) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'docdigital_alertas',
      'Alertas de documentos',
      channelDescription: 'Notificações de vencimento de documentos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      corpo,
      details,
    );
  }
}