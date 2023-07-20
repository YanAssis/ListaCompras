// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:aula_1/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/global_constant.dart';
import '../models/produto.dart';
import '../repositories/produtos_repository.dart';

class EditarProdutoPage extends StatefulWidget {
  Produto? produto;
  EditarProdutoPage({Key? mykey, this.produto}) : super(key: mykey);
  @override
  State<EditarProdutoPage> createState() => _EditarProdutoPageState();
}

class _EditarProdutoPageState extends State<EditarProdutoPage> {
  final user = FirebaseAuth.instance.currentUser;

  final formKey = GlobalKey<FormState>();

  var nomeController = TextEditingController();

  var precoController = TextEditingController();

  var prioridadeController = 0;
  List<String> prioridadeList = ['0', '1', '2', '3', '4'];
  final dropValue = ValueNotifier('');

  String selectedImagePath = '';

  late Produto novoProduto;

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  Future pickImageGalery() async {
    try {
      final XFile? image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (image != null) {
        return image.path;
      } else {
        return '';
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera() async {
    try {
      final XFile? image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 75);
      if (image != null) {
        return image.path;
      } else {
        return '';
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  createImageDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Selecione uma imagem'),
              content: const Text('Deseja selecionar a imagem da:'),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () async {
                    selectedImagePath = await pickImageGalery();
                    print('Image_Path:-');
                    print(selectedImagePath);

                    if (selectedImagePath != '') {
                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("No Image Captured !"),
                      ));
                    }
                  },
                  child: const Text('Galeria'),
                ),
                MaterialButton(
                  onPressed: () async {
                    selectedImagePath = await pickImageCamera();
                    print('Image_Path:-');
                    print(selectedImagePath);

                    if (selectedImagePath != '') {
                      Navigator.pop(context);
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("No Image Captured !"),
                      ));
                    }
                  },
                  child: const Text('Câmera'),
                )
              ]);
        });
  }

  updateProduto() async {
    var temAlteracao = false;

    var nome = nomeController.text;
    if (nome.isEmpty) {
      nome = widget.produto!.nome;
    } else {
      temAlteracao = true;
    }

    var preco = precoController.text;
    if (preco.isEmpty) {
      preco = widget.produto!.preco.toString();
    } else {
      temAlteracao = true;
    }

    var prioridade = prioridadeController;

    var imageurl = '';
    if (selectedImagePath != '') {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$nome.jpg_${user.hashCode.toString()}');
      await ref.putFile(File(selectedImagePath));
      var value = (await ref.getDownloadURL()).toString();
      imageurl = value.toString();
      temAlteracao = true;
    } else {
      imageurl = widget.produto!.imageurl;
    }

    String oldNome = widget.produto!.nome;
    String oldImageurl = widget.produto!.imageurl;
    double oldPreco = widget.produto!.preco;
    int oldPrioridade = widget.produto!.prioridade;

    if (oldPrioridade == prioridade && !temAlteracao) {
      const snackBar = SnackBar(
        content: Text('Nenhuma alteração identificada'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      novoProduto = Produto(
        nome: nome,
        imageurl: imageurl,
        preco: double.parse(preco),
        prioridade: prioridade,
        isComprado: false,
      );

      try {
        Provider.of<ProdutoRepository>(context, listen: false)
            .updateProduct(widget.produto!, novoProduto);
      } finally {
        const snackBar = SnackBar(
          content: Text(' Produto atualizado !'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        navigatorState.currentState
            ?.push(MaterialPageRoute(builder: (_) => HomePage()));
      }
    }
  }

  createProduto() async {
    var nome = nomeController.text;
    var imageurl = '';

    var preco = precoController.text;
    var prioridade = prioridadeController;

    if (selectedImagePath != '') {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$nome.jpg_${user.hashCode.toString()}');
      await ref.putFile(File(selectedImagePath));
      var value = (await ref.getDownloadURL()).toString();
      imageurl = value.toString();
    }

    novoProduto = Produto(
      nome: nome,
      imageurl: imageurl,
      preco: double.parse(preco),
      prioridade: prioridade,
      isComprado: false,
    );

    try {
      Provider.of<ProdutoRepository>(context, listen: false)
          .createNewProduct(novoProduto);
    } finally {
      const snackBar = SnackBar(
        content: Text('Novo Produto Criado !'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String photoUrl = "";
    Produto? pParameter = widget.produto;

    if (pParameter != null) {
      photoUrl = pParameter.imageurl;
      prioridadeController = pParameter.prioridade;
    }

    returnavatar() {
      if (pParameter == null) {
        return CircleAvatar(
          radius: 80,
          backgroundColor: Colors.black,
          child: (selectedImagePath.isNotEmpty)
              ? CircleAvatar(
                  radius: 80,
                  backgroundImage: FileImage(File(selectedImagePath)))
              : const CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.image_not_supported),
                ),
        );
      } else {
        return CircleAvatar(
          radius: 80,
          backgroundColor: Colors.black,
          child: (selectedImagePath.isNotEmpty)
              ? CircleAvatar(
                  radius: 80,
                  backgroundImage: FileImage(File(selectedImagePath)))
              : CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(photoUrl),
                ),
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: pParameter == null
              ? const Text('Novo Produto')
              : Text('Editar ${pParameter.nome}'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(children: [
                SizedBox(width: 120, height: 120, child: returnavatar()),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey),
                      child: IconButton(
                          icon: const Icon(Icons.edit),
                          iconSize: 20,
                          onPressed: () {
                            createImageDialog(context);
                          }),
                    )),
              ]),
              const SizedBox(height: 10),
              Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: TextFormField(
                          controller: nomeController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: pParameter == null
                                  ? 'Nome do Produto'
                                  : pParameter.nome,
                              labelText: 'Nome do Produto',
                              prefixIcon:
                                  const Icon(Icons.shopping_cart_rounded)),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: TextFormField(
                          controller: precoController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: pParameter == null
                                  ? 'Preço'
                                  : pParameter.preco.toString(),
                              labelText: 'Preço',
                              prefixIcon:
                                  const Icon(Icons.price_check_rounded)),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => newValue.copyWith(
                                text: newValue.text.replaceAll(',', '.'),
                              ),
                            ),
                          ],
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          child: Row(
                            children: <Widget>[
                              const Expanded(
                                child: Text('Prioridade:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Expanded(
                                child: ValueListenableBuilder(
                                    valueListenable: dropValue,
                                    builder: (BuildContext context,
                                        String value, _) {
                                      return DropdownButton<String>(
                                          hint: const Center(
                                              child: Text('Selecione')),
                                          value: (value.isEmpty ||
                                                  (pParameter != null &&
                                                      value.isEmpty))
                                              ? pParameter?.prioridade
                                                  .toString()
                                              : value,
                                          onChanged: (escolha) {
                                            dropValue.value =
                                                escolha.toString();
                                            prioridadeController =
                                                int.parse(escolha!);
                                          },
                                          items: prioridadeList
                                              .map((op) => DropdownMenuItem(
                                                  value: op,
                                                  child: Text(op,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 18))))
                                              .toList());
                                    }),
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ElevatedButton(
                          onPressed: () {
                            pParameter == null
                                ? createProduto()
                                : updateProduto();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: (loading)
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ]
                                : [
                                    const Icon(Icons.check),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: pParameter == null
                                          ? const Text('Novo Produto')
                                          : Text('Editar ${pParameter.nome}'),
                                    )
                                  ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ]),
          ),
        ));
  }
}
