// ignore_for_file: avoid_print

import 'package:aula_1/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants/global_constant.dart';
import '../models/produto.dart';
import '../pages/produto_detalhe.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            badge: true, sound: true, alert: true);
    getDeviceFirebaseToken();
    _onMessage();
    _onMessageOpenedApp();
  }

  getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('Token: $token');
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showNotification(CustomNotification(
            id: android.hashCode,
            title: notification.title!,
            body: notification.body!,
            payload: message.data['produto'] ?? ''));
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String dadosproduto = message.data['produto'] ?? '';
    if (dadosproduto.isNotEmpty) {
      late Produto novoproduto;
      try {
        novoproduto = Produto.fromJson(dadosproduto);
      } finally {
        navigatorState.currentState?.push(MaterialPageRoute(
            builder: (_) => ProdutoDetalhePage(produto: novoproduto)));
      }
    }
  }
}
