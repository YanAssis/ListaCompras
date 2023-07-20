// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:aula_1/widgets/auth_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/global_constant.dart';
import '../services/auth_service.dart';

class EditarUsuarioPage extends StatefulWidget {
  const EditarUsuarioPage({super.key});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final user = FirebaseAuth.instance.currentUser;

  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();

  String selectedImagePath = '';

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  createLogOffDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Log Off necessário'),
              content: const Text(
                  'Informações de cadastro foram alteradas, logoff necessário'),
              actions: <Widget>[
                MaterialButton(
                  onPressed: () {
                    context.read<AuthService>().logout();
                    navigatorState.currentState?.push(
                        MaterialPageRoute(builder: (_) => const AuthCheck()));
                  },
                  child: const Text('Ok'),
                )
              ]);
        });
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

  @override
  Widget build(BuildContext context) {
    String photoUrl = "";

    if (user != null) {
      for (UserInfo profile in user!.providerData) {
        if (profile.photoURL != null && profile.photoURL!.isNotEmpty) {
          photoUrl = profile.photoURL!;
        }
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Editar informações'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.black,
                      backgroundImage: selectedImagePath != ''
                          ? FileImage(File(selectedImagePath))
                          : null,
                      child: (selectedImagePath == '' && photoUrl.isNotEmpty)
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(photoUrl))
                          : null),
                ),
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
                          controller: nome,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Novo nome',
                              prefixIcon: Icon(Icons.person)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: TextFormField(
                          controller: email,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Novo Email',
                              prefixIcon: Icon(Icons.email)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: TextFormField(
                          controller: senha,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nova Senha',
                              prefixIcon: Icon(Icons.fingerprint)),
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value!.length < 6) {
                              return 'Sua senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ElevatedButton(
                          onPressed: () {
                            checkUpdates();
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
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Atualizar dados',
                                        style: TextStyle(fontSize: 20),
                                      ),
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

  checkUpdates() async {
    setState(() => loading = true);

    bool updateEmailSenha = false;
    try {
      if (nome.text.isNotEmpty) {
        await context.read<AuthService>().updateName(nome.text);
      }
      if (selectedImagePath.isNotEmpty) {
        await context.read<AuthService>().updatePhoto(selectedImagePath);
      }
      if (email.text.isNotEmpty) {
        await context.read<AuthService>().updateEmail(email.text);
        updateEmailSenha = true;
      }
      if (senha.text.isNotEmpty) {
        await context.read<AuthService>().updatePassword(senha.text);
        updateEmailSenha = true;
      }
    } on AuthException catch (e) {
      setState(() => loading = false);
      updateEmailSenha = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso')));
    }

    if (updateEmailSenha) {
      createLogOffDialog(context);
    }
  }
}
