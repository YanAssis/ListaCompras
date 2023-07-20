import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocationController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  String erro = '';
  String endereco = '';

  GeoLocationController() {
    getPosicaoUsuario();
  }

  getPosicaoUsuario() async {
    try {
      Position posicao = await _posicaoAtualUsuario();
      lat = posicao.latitude;
      long = posicao.longitude;
    } catch (e) {
      erro = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtualUsuario() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }

  getAdressFromName(String queryEndereco) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(queryEndereco);
    var firstAddress = addresses.first;
    //print("${firstAddress.featureName} : ${firstAddress.coordinates}");
  }

  getAdressFromCoordinates(Coordinates coord) async {
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coord);
    var firstAddress = addresses.first;
    endereco = "${firstAddress.subAdminArea} - ${firstAddress.adminArea}";
    //print("${firstAddress.subAdminArea} - ${firstAddress.adminArea}");

    return firstAddress;
  }
}
