import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/global_constant.dart';
import '../models/produto.dart';
import '../pages/produto_detalhe.dart';

class CustomNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  CustomNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

class NotificationService {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;

  NotificationService() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    _setupNotifications();
  }

  _setupNotifications() async {
    await _initializeNotifications();
  }

  _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: android,
      ),
      onDidReceiveNotificationResponse: (details) {
        _onSelectNotification(details.payload);
      },
    );
  }

  _onSelectNotification(String? payload) {
    // Produto novoprod = Produto.fromJson(payload as Map<String, dynamic>);
    if (payload != null && payload.isNotEmpty) {
      late Produto novoproduto;
      try {
        novoproduto = Produto.fromJson(payload);
      } finally {
        navigatorState.currentState?.push(MaterialPageRoute(
            builder: (_) => ProdutoDetalhePage(produto: novoproduto)));
      }
    }
  }

  showNotification(CustomNotification notification) {
    androidDetails = const AndroidNotificationDetails(
        'notifications_x', 'Lembretes',
        channelDescription: 'Este canal é para lembretes!',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true);

    localNotificationsPlugin.show(notification.id, notification.title,
        notification.body, NotificationDetails(android: androidDetails),
        payload: notification.payload);
  }
}
