import 'package:aula_1/models/produto.dart';
import 'package:aula_1/repositories/produtos_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CompradosPage extends StatefulWidget {
  const CompradosPage({super.key});

  @override
  State<CompradosPage> createState() => _CompradosPageState();
}

class _CompradosPageState extends State<CompradosPage> {
  final dropValue = ValueNotifier('');
  final orderDropOptions = ProdutoRepository.sortList;

  NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  List<Produto> selecionadas = [];

  late ProdutoRepository produtos;

  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: const Text('Comprados'),
        actions: [
          Center(
              child: ValueListenableBuilder(
                  valueListenable: dropValue,
                  builder: (BuildContext context, String value, _) {
                    return DropdownButton<String>(
                        hint: const Center(child: Text('Ordernar')),
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selecionadas = [];
            });
          },
        ),
        title: Text('${selecionadas.length} selecionadas'),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        toolbarTextStyle: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyMedium,
        titleTextStyle: const TextTheme(
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

    List<Produto> tabela =
        produtos.tabela.where((f) => f.isComprado == true).toList();

    return Scaffold(
      appBar: appBarDinamica(),
      body: Consumer<ProdutoRepository>(builder: (context, comprados, child) {
        return tabela.isEmpty
            ? const ListTile(
                leading: Icon(Icons.question_mark),
                title: Text('Ainda não há itens comprados'),
              )
            : ListView.separated(
                itemBuilder: (BuildContext context, int produto) {
                  return ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    leading: (selecionadas.contains(tabela[produto]))
                        ? const CircleAvatar(
                            child: Icon(Icons.check),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(tabela[produto].prioridade.toString()),
                          ),
                    title: Text(
                      tabela[produto].nome,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      real.format(tabela[produto].preco),
                      style: const TextStyle(fontSize: 15),
                    ),
                    selected: selecionadas.contains(tabela[produto]),
                    selectedTileColor: Colors.indigo[50],
                    onLongPress: () {
                      setState(() {
                        (selecionadas.contains(tabela[produto]))
                            ? selecionadas.remove(tabela[produto])
                            : selecionadas.add(tabela[produto]);
                      });
                    },
                  );
                },
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, ___) => const Divider(),
                itemCount: tabela.length,
              );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selecionadas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  for (var produto in selecionadas) {
                    produto.isComprado = false;
                    Provider.of<ProdutoRepository>(context, listen: false)
                        .buyProduct(produto);
                  }
                  selecionadas = [];
                });
              },
              icon: const Icon(Icons.unarchive),
              label: const Text(
                'REMOVER',
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
