import 'package:aula_1/pages/editar_produto_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

import '../constants/global_constant.dart';
import '../models/produto.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProdutoDetalhePage extends StatefulWidget {
  const ProdutoDetalhePage({super.key, required this.produto});

  final Produto produto;

  @override
  State<ProdutoDetalhePage> createState() => _ProdutoDetalhePageState();
}

class _ProdutoDetalhePageState extends State<ProdutoDetalhePage> {
  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');

  compartilharProduto(Produto produto) {}

  @override
  Widget build(BuildContext context) {
    final Produto produto = widget.produto;

    String photoUrl = "";

    if (produto.imageurl != '') {
      photoUrl = produto.imageurl;
    }

    AuthService auth = Provider.of<AuthService>(context);

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (auth.usuario == null) {
      return const LoginPage();
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Detalhes de: ${produto.nome}'),
            actions: [
              IconButton(
                  onPressed: () {
                    navigatorState.currentState?.push(MaterialPageRoute(
                        builder: (_) => EditarProdutoPage(
                              produto: produto,
                            )));
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    var nome = produto.nome;
                    var preco = produto.preco;
                    SocialShare.shareOptions(
                        '$nome por apenas: ${real.format(preco)}');
                  },
                  icon: const Icon(Icons.share))
            ],
          ),
          body: Center(
              heightFactor: 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.black,
                      child: (photoUrl.isNotEmpty)
                          ? CircleAvatar(
                              radius: 90,
                              backgroundImage: NetworkImage(photoUrl))
                          : const CircleAvatar(
                              radius: 90,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.image_not_supported),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nome: ${produto.nome}',
                      style: const TextStyle(color: Colors.black, fontSize: 32),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Preço: ${real.format(produto.preco)}',
                      style: const TextStyle(color: Colors.black, fontSize: 32),
                    ),
                  ])));
    }
  }
}
