import 'dart:convert';

class Produto {
  Produto({
    required this.nome,
    required this.imageurl,
    required this.preco,
    required this.prioridade,
    required this.isComprado,
  });

  String nome;
  String imageurl;
  double preco;
  int prioridade;
  bool isComprado;

  factory Produto.fromJson(dynamic json) {
    var data = jsonDecode(json.toString());

    final nome = data['nome'];
    final imageurl = data['imageurl'];
    final preco = double.tryParse(data['preco']);
    final prioridade = int.tryParse(data['prioridade']);
    final bool isComprado;

    final isCompradoString = data['isComprado'];
    if (isCompradoString == 'true') {
      isComprado = true;
    } else {
      isComprado = false;
    }

    return Produto(
        nome: nome,
        imageurl: imageurl,
        preco: preco!,
        prioridade: prioridade!,
        isComprado: isComprado);
  }
}
