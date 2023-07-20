import 'package:aula_1/repositories/produtos_repository.dart';
import 'package:aula_1/services/auth_service.dart';
import 'package:aula_1/services/firebase_messaging_service.dart';
import 'package:aula_1/services/geolocation_service.dart';
import 'package:aula_1/services/notification_service.dart';
import 'package:aula_1/widgets/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/global_constant.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Provider.debugCheckInvalidValueType = null;

  runApp(MediaQuery(
    data: const MediaQueryData(),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(
            create: (context) =>
                ProdutoRepository(auth: context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => GeoLocationController()),
        Provider<NotificationService>(
            create: (context) => NotificationService()),
        Provider<FirebaseMessagingService>(
            create: (context) =>
                FirebaseMessagingService(context.read<NotificationService>())),
      ],
      child: MaterialApp(navigatorKey: navigatorState, home: const AuthCheck()),
    ),
  ));

  FlutterNativeSplash.remove();
}
