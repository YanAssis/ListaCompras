import 'dart:collection';
import 'package:aula_1/databases/db_firestore.dart';
import 'package:aula_1/models/produto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../services/auth_service.dart';

class ProdutoRepository extends ChangeNotifier {
  late FirebaseFirestore db;
  late AuthService auth;

  static final List<Produto> _lista = [];
  UnmodifiableListView<Produto> get tabela => UnmodifiableListView(_lista);

  ProdutoRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readProdutos();
  }

  _startFirestore() {
    db = DBFireStore.get();
  }

  _readProdutos() async {
    if (auth.usuario != null) {
      _lista.clear();

      final snapshot =
          await db.collection('usuarios/${auth.usuario!.uid}/produtos').get();

      for (var doc in snapshot.docs) {
        var nome = doc.get('nome');
        var imageurl = doc.get('imageurl');
        double preco = doc.get('preco').toDouble();
        int prioridade = doc.get('prioridade').toInt();
        var isCompradoString = doc.get('isComprado');
        bool isComprado;

        if (isCompradoString == 'true') {
          isComprado = true;
        } else {
          isComprado = false;
        }

        Produto produto = Produto(
            nome: nome,
            imageurl: imageurl,
            preco: preco,
            prioridade: prioridade,
            isComprado: isComprado);

        _lista.add(produto);
      }
    }
    notifyListeners();
  }

  createNewProduct(Produto produto) async {
    try {
      await db
          .collection('usuarios/${auth.usuario!.uid}/produtos')
          .doc(produto.nome)
          .set({
        'nome': produto.nome,
        'preco': produto.preco,
        'imageurl': produto.imageurl,
        'prioridade': produto.prioridade,
        'isComprado': 'false',
      });
      _readProdutos();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    notifyListeners();
  }

  updateProduct(Produto oldP, Produto newP) async {
    String oldNome = oldP.nome;
    String oldImageurl = oldP.imageurl;
    double oldPreco = oldP.preco;
    int oldPrioridade = oldP.prioridade;

    String newNome = newP.nome;
    String newImageurl = newP.imageurl;
    double newPreco = newP.preco;
    int newPrioridade = newP.prioridade;

    if (oldNome != newNome) {
      oldNome = newNome;
    }

    if (oldImageurl != newImageurl) {
      oldImageurl = newImageurl;
    }

    if (oldPreco != newPreco) {
      oldPreco = newPreco;
    }

    if (oldPrioridade != newPrioridade) {
      oldPrioridade = newPrioridade;
    }

    try {
      await db
          .collection('usuarios/${auth.usuario!.uid}/produtos')
          .doc(oldP.nome)
          .update({
        'nome': oldNome,
        'preco': oldPreco,
        'imageurl': oldImageurl,
        'prioridade': oldPrioridade,
      });
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    _readProdutos();
    notifyListeners();
  }

  removeProduct(Produto produto) async {
    try {
      await db
          .collection('usuarios/${auth.usuario!.uid}/produtos')
          .doc(produto.nome)
          .delete();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    _readProdutos();
    notifyListeners();
  }

  buyProduct(Produto produto) async {
    String isCompradoString;
    if (produto.isComprado) {
      isCompradoString = 'true';
    } else {
      isCompradoString = 'false';
    }

    try {
      await db
          .collection('usuarios/${auth.usuario!.uid}/produtos')
          .doc(produto.nome)
          .update({
        'isComprado': isCompradoString,
      });
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
    _readProdutos();
    notifyListeners();
  }

  static List<String> sortList = ['Nome', 'Prioridade', 'Preço'];

  sortByList(String value) {
    switch (value) {
      case "Prioridade":
        {
          _lista.sort(
              (Produto a, Produto b) => a.prioridade.compareTo(b.prioridade));
        }
        break;

      case "Preço":
        {
          _lista.sort((Produto a, Produto b) => a.preco.compareTo(b.preco));
        }
        break;

      case "Nome":
        {
          _lista.sort((Produto a, Produto b) => a.nome.compareTo(b.nome));
        }
        break;
    }
    notifyListeners();
  }

  /* static List<Produto> tabela = [
    Produto(
      nome: 'Bitcoin',
      preco: 164603.00,
      prioridade: 0,
      isComprado: false,
    ),
    Produto(
      nome: 'Ethereum',
      preco: 9716.00,
      prioridade: 1,
      isComprado: false,
    ),
    Produto(
      nome: 'XRP',
      preco: 3.34,
      prioridade: 2,
      isComprado: true,
    ),
    Produto(
      nome: 'Cardano',
      preco: 6.32,
      prioridade: 3,
      isComprado: false,
    ),
    Produto(
      nome: 'USD Coin',
      preco: 5.02,
      prioridade: 2,
      isComprado: true,
    ),
    Produto(
      nome: 'Litecoin',
      preco: 669.93,
      prioridade: 1,
      isComprado: false,
    ),
  ];
  */
}
