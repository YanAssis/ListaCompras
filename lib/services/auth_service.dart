// ignore_for_file: avoid_print, empty_catches
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  final googleSignIn = GoogleSignIn();

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    print(_auth.currentUser?.providerData.toString());
    notifyListeners();
  }

  registrar(String email, String senha, String nome) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      await _auth.currentUser?.updateDisplayName(nome);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Este email já está cadastrado');
      }
    }
  }

  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente');
      }
    }
  }

  googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw AuthException('Erro ao logar com o Google');
    _user = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      _getUser();
    } on FirebaseAuthException {}
  }

  updateName(String nome) async {
    try {
      await _auth.currentUser?.updateDisplayName(nome);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        logout();
        throw AuthException(
            'Para executar essa operação é necessário fazer login novamente');
      }
    }
  }

  updatePhoto(String photoPath) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profilepic.jpg_${_user.hashCode.toString()}');
    await ref.putFile(File(photoPath));
    ref.getDownloadURL().then((value) async {
      try {
        await _auth.currentUser?.updatePhotoURL(value);
        _getUser();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          logout();
          throw AuthException(
              'Para executar essa operação é necessário fazer login novamente');
        }
      }
    });
  }

  updateEmail(String email) async {
    try {
      await _auth.currentUser?.updateEmail(email);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        logout();
        throw AuthException(
            'Para executar essa operação é necessário fazer login novamente');
      }
    }
  }

  updatePassword(String senha) async {
    try {
      await _auth.currentUser?.updatePassword(senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        logout();
        throw AuthException(
            'Para executar essa operação é necessário fazer login novamente');
      }
    }
  }

  logout() async {
    if (_user != null) await googleSignIn.disconnect();
    await _auth.signOut();

    _getUser();
  }
}
