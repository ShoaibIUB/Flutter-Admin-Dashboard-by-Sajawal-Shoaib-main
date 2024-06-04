import 'package:firebase_auth/firebase_auth.dart';
import 'package:flareline/entity/user_entity.dart';
import 'package:flareline/provider/firebase_provider.dart';
import 'package:flareline/provider/store_provider.dart';
import 'package:flareline/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class SignInProvider with ChangeNotifier {
  final box = GetStorage();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  SignInProvider(BuildContext ctx) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailController.text = ctx.read<StoreProvider>().email;
    
    // Default email and password
    if (emailController.text.isEmpty || emailController.text == 'example@example.com') {
      emailController.text = 'example@example.com'; // Default email
      passwordController.text = 'password'; // Default password
    }
  }

  Future<void> signIn(BuildContext context) async {
    debugPrint('signIn method called'); // Debug step
    debugPrint('Email: ${emailController.text}, Password: ${passwordController.text}'); // Debug step

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarUtil.showSnack(context, 'Please enter your info');
      return;
    }
    if (passwordController.text.trim().length < 6) {
      SnackBarUtil.showSnack(context, 'Please enter 6+ Characters password');
      return;
    }

    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      debugPrint('credential: $credential'); // Debug step
      if (credential.user != null) {
        User? user = credential.user;
        if (user != null) {
          UserEntity userEntity =
              await context.read<FirebaseProvider>().login(user);
          context.read<StoreProvider>().saveLogin(userEntity);
          context.read<StoreProvider>().saveEmail(userEntity.email);
          Navigator.of(context).popAndPushNamed('/');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackBarUtil.showSnack(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        SnackBarUtil.showSnack(context, 'Wrong password provided for that user.');
      }
    } catch (e) {
      SnackBarUtil.showSnack(context, e.toString());
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential =
          await context.read<FirebaseProvider>().signInWithGoogle();
      User? user = userCredential.user;
      if (user != null) {
        UserEntity userEntity =
            await context.read<FirebaseProvider>().login(user);
        context.read<StoreProvider>().saveLogin(userEntity);
        Navigator.of(context).popAndPushNamed('/');
      } else {
        SnackBarUtil.showSnack(context, 'Sign In Fail');
      }
    } catch (e) {
      SnackBarUtil.showSnack(context, e.toString());
    }
  }

  Future<void> signInWithGithub(BuildContext context) async {
    try {
      UserCredential userCredential =
          await context.read<FirebaseProvider>().signInWithGithub();
      User? user = userCredential.user;
      if (user != null) {
        UserEntity userEntity =
            await context.read<FirebaseProvider>().login(user);
        context.read<StoreProvider>().saveLogin(userEntity);
        Navigator.of(context).popAndPushNamed('/');
      } else {
        SnackBarUtil.showSnack(context, 'Sign In Fail');
      }
    } catch (e) {
      SnackBarUtil.showSnack(context, e.toString());
    }
  }
}
