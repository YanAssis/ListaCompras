import 'package:aula_1/models/produto.dart';
import 'package:aula_1/pages/comprados_page.dart';
import 'package:aula_1/pages/editar_produto_page.dart';
import 'package:aula_1/pages/pendentes_page.dart';
import 'package:aula_1/pages/todosprodutos_page.dart';
import 'package:aula_1/pages/usuario_configuracoes.dart';
import 'package:aula_1/services/firebase_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/global_constant.dart';
import '../repositories/produtos_repository.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;
  late PageController pc;

  late ProdutoRepository produtos;

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    pc = PageController(initialPage: paginaAtual);
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false)
        .initialize();
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  void adicionarProduto() {
    var nomeController = TextEditingController();
    var precoController = TextEditingController();
    var prioridadeController = 0;

    late Produto novoProduto;

    List<String> prioridadeList = ['0', '1', '2', '3', '4'];
    final dropValue = ValueNotifier('');

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                              hintText: 'Nome do produto'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false),
                          controller: precoController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => newValue.copyWith(
                                text: newValue.text.replaceAll(',', '.'),
                              ),
                            ),
                          ],
                          decoration:
                              const InputDecoration(hintText: 'Preço R\$'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ValueListenableBuilder(
                            valueListenable: dropValue,
                            builder: (BuildContext context, String value, _) {
                              return DropdownButton<String>(
                                  hint: const Center(child: Text('Prioridade')),
                                  value: (value.isEmpty) ? null : value,
                                  onChanged: (escolha) {
                                    dropValue.value = escolha.toString();
                                    prioridadeController = int.parse(escolha!);
                                  },
                                  items: prioridadeList
                                      .map((op) => DropdownMenuItem(
                                          value: op, child: Text(op)))
                                      .toList());
                            }),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  var nome = nomeController.text;
                  var preco = precoController.text;
                  var prioridade = prioridadeController;

                  novoProduto = Produto(
                    nome: nome,
                    imageurl: '',
                    preco: double.parse(preco),
                    prioridade: prioridade,
                    isComprado: false,
                  );

                  try {
                    Provider.of<ProdutoRepository>(context, listen: false)
                        .createNewProduct(novoProduto);
                  } finally {
                    showNotification();
                  }

                  Navigator.pop(context);
                },
                child: const Text('Criar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        });
  }

  showNotification() {
    setState(() {
      Provider.of<NotificationService>(context, listen: false).showNotification(
          CustomNotification(
              id: 1, title: 'Teste', body: 'Acesse o app!', payload: '/teste'));
    });
  }

  @override
  Widget build(BuildContext context) {
    //produtos = Provider.of<ProdutoRepository>(context);
    produtos = context.watch<ProdutoRepository>();

    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: setPaginaAtual,
        children: const [
          PendentesPage(),
          CompradosPage(),
          TodosProdutosPage(),
          UserConfiguracoesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Pendente',
              backgroundColor: Colors.grey),
          BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: 'Comprados',
              backgroundColor: Colors.grey),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              label: 'Todos',
              backgroundColor: Colors.grey),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
              backgroundColor: Colors.grey),
        ],
        onTap: (pagina) {
          pc.animateToPage(pagina,
              duration: const Duration(microseconds: 1000), curve: Curves.ease);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigatorState.currentState
              ?.push(MaterialPageRoute(builder: (_) => EditarProdutoPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
