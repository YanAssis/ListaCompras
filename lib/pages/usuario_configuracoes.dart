import 'package:aula_1/constants/global_constant.dart';
import 'package:aula_1/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/geolocation_service.dart';
import 'editar_usuario_page.dart';

class UserConfiguracoesPage extends StatefulWidget {
  const UserConfiguracoesPage({super.key});

  @override
  State<UserConfiguracoesPage> createState() => _UserConfiguracoesPageState();
}

class _UserConfiguracoesPageState extends State<UserConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final local = context.watch<GeoLocationController>();
    var lat = local.lat;
    var long = local.long;
    local.getAdressFromCoordinates(Coordinates(lat, long));
    var endereco = local.endereco;

    String photoUrl = "";

    if (user != null) {
      for (UserInfo profile in user.providerData) {
        //String providerId = "";
        // Id of the provider (ex: google.com)
        //providerId = profile.providerId;
        //if (providerId == 'google.com') {

        if (profile.photoURL != null && profile.photoURL!.isNotEmpty) {
          photoUrl = profile.photoURL!;
        }
      }
    }

    Future<void> openMap(String lat, String long) async {
      String googleURL =
          'https://www.google.com/maps/search/?api=1&query=$lat,$long';

      final Uri url = Uri.parse(googleURL);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Compras'),
          actions: [
            IconButton(
                onPressed: () {
                  navigatorState.currentState?.push(MaterialPageRoute(
                      builder: (_) => const EditarUsuarioPage()));
                },
                icon: const Icon(Icons.edit))
          ],
        ),
        body: Column(children: [
          const SizedBox(
            height: 8,
          ),
          (photoUrl.isNotEmpty)
              ? CircleAvatar(
                  radius: 60, backgroundImage: NetworkImage(photoUrl))
              : const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.image_not_supported),
                ),
          const SizedBox(height: 8),
          Text(
            'Nome: ${user?.displayName!}',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Email: ${user?.email!}',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Localização -  $endereco',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
          ElevatedButton(
              onPressed: () {
                openMap(lat.toString(), long.toString());
              },
              child: const Text('Abrir no Maps')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: OutlinedButton(
              onPressed: () => context.read<AuthService>().logout(),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sair do App',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]));
  }
}
