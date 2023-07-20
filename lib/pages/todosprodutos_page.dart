// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'package:aula_1/constants/global_constant.dart';
import 'package:aula_1/models/produto.dart';
import 'package:aula_1/pages/produto_detalhe.dart';
import 'package:aula_1/repositories/produtos_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodosProdutosPage extends StatefulWidget {
  const TodosProdutosPage({Key? key}) : super(key: key);

  @override
  _TodosProdutosPageState createState() => _TodosProdutosPageState();
}

class _TodosProdutosPageState extends State<TodosProdutosPage> {
  final dropValue = ValueNotifier('');
  final orderDropOptions = ProdutoRepository.sortList;

  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  List<Produto> selecionadas = [];

  late ProdutoRepository produtos;

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: Text('Todos'),
        actions: [
          Center(
              child: ValueListenableBuilder(
                  valueListenable: dropValue,
                  builder: (BuildContext context, String value, _) {
                    return DropdownButton<String>(
                        hint: Center(child: const Text('Ordernar')),
                        value: (value.isEmpty) ? null : value,
                        onChanged: (escolha) {
                          dropValue.value = escolha.toString();
                          setState(() {
                            produtos.sortByList(escolha!);
                          });
                        },
                        items: orderDropOptions
                            .map((op) =>
                                DropdownMenuItem(value: op, child: Text(op)))
                            .toList());
                  }))
        ],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        title: Text('${selecionadas.length} selecionadas'),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
        toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).titleLarge,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //produtos = Provider.of<ProdutoRepository>(context);
    produtos = context.watch<ProdutoRepository>();

    List<Produto> tabela = produtos.tabela;

    return Scaffold(
      appBar: appBarDinamica(),
      body: Consumer<ProdutoRepository>(
          builder: (context, produtosrepositorio, child) {
        return tabela.isEmpty
            ? const ListTile(
                leading: Icon(Icons.question_mark),
                title: Text(
                    'Ainda não há produtos criados, para criar clique no botão +'),
              )
            : ListView.separated(
                itemBuilder: (BuildContext context, int produto) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    leading: (selecionadas.contains(tabela[produto]))
                        ? CircleAvatar(
                            child: Icon(Icons.check),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Text(tabela[produto].prioridade.toString()),
                          ),
                    title: Text(
                      tabela[produto].nome,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      real.format(tabela[produto].preco),
                      style: TextStyle(fontSize: 15),
                    ),
                    selected: selecionadas.contains(tabela[produto]),
                    selectedTileColor: Colors.indigo[50],
                    onTap: () {
                      // var payloadnot =  '{ "nome": "${tabela[produto].nome}","preco": "${tabela[produto].preco}","prioridade": "${tabela[produto].prioridade}","isComprado": "${tabela[produto].isComprado.toString()}"}';
                      /*setState(() {
                        Provider.of<NotificationService>(context, listen: false)
                            .showNotification(CustomNotification(
                                id: 1,
                                title: 'Sua ista de compras',
                                body:
                                    '${tabela[produto].nome} por apenas: ${real.format(tabela[produto].preco)}',
                                payload: payloadnot));
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProdutoDetalhePage(produto: tabela[produto])));*/

                      navigatorState.currentState?.push(MaterialPageRoute(
                          builder: (_) =>
                              ProdutoDetalhePage(produto: tabela[produto])));
                    },
                    onLongPress: () {
                      setState(() {
                        (selecionadas.contains(tabela[produto]))
                            ? selecionadas.remove(tabela[produto])
                            : selecionadas.add(tabela[produto]);
                      });
                    },
                  );
                },
                padding: EdgeInsets.all(16),
                separatorBuilder: (_, ___) => Divider(),
                itemCount: tabela.length,
              );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  for (var produto in selecionadas) {
                    Provider.of<ProdutoRepository>(context, listen: false)
                        .removeProduct(produto);
                  }
                  selecionadas = [];
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text(
                'DELETAR',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
