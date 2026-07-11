import 'dart:io';

import 'package:budlee_app/config/cubit/register/register_states.dart';
import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(InitRegisterState());
  static RegisterCubit get(context) => BlocProvider.of(context);

  final ImagePicker imagePicker = ImagePicker();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var birthdayController = TextEditingController();
  var passwordConfirmedController = TextEditingController();
  var phonController = TextEditingController();
  var avatarController = TextEditingController();
  var genderController = TextEditingController();
  var nameController = TextEditingController();
  var registerFormKey = GlobalKey<FormState>();
  var value = TextEditingController();
  var rightsChecked = false;
  var termsChecked = false;
  var redEye = false;
  bool visibleOff = true;
  bool visibleOff2 = true;
  var redEyeChecked = false;
  Icon redEyeIcon = Icon(Icons.visibility_off);
  Icon redEyeIcon2 = Icon(Icons.visibility_off);

  void changeVisibilityOne() {
    visibleOff = !visibleOff;
    redEye = !redEye;
    if (redEye) {
      redEyeIcon = Icon(Icons.visibility);
    } else {
      redEyeIcon = Icon(Icons.visibility_off);
    }
    emit(RegisterChangeVisibilityState());
  }

  void changeVisibilityTwo() {
    visibleOff2 = !visibleOff2;
    redEye = !redEye;
    if (redEye) {
      redEyeIcon2 = Icon(Icons.visibility);
    } else {
      redEyeIcon2 = Icon(Icons.visibility_off);
    }
    emit(RegisterChangeVisibilityState());
  }

  void changeRightsChecked() {
    rightsChecked = !rightsChecked;
    emit(RegisterChangeVisibilityState());
  }

  void changeTermsChecked() {
    termsChecked = !termsChecked;
    emit(RegisterChangeVisibilityState());
  }

  void userRegister({
    required String email,
    required String password,
    required String name,
    String? bio,
    List<File>? gallery,
    required String birthday,
    required String phone,
  }) {
    emit(RegisterLoadingState());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email.trim(), password: password)
        .then((value) {
          print(value.user!.email);
          print(value.user!.uid);
          createUserData(
            email: email,
            password: password,
            name: name,
            bio: bio ?? 'Write your bio...',
            gallery: gallery ?? [],
            birthday: birthday,
            phone: phone,
            uId: value.user!.uid,
            isEmailVerified: false,
          );
        })
        .catchError((error) {
          emit(RegisterErrorState(error.toString()));
        });
  }

  void createUserData({
    required String email,
    required String password,
    required String name,
    required String birthday,
    List<File>? gallery,
    String? bio,
    required String phone,
    String? imageUrl,
    String? coverImageUrl,
    required String uId,
    required bool isEmailVerified,
  }) {
    userModel model = userModel(
      email: email,
      password: password,
      name: name,
      birthday: birthday,
      imagesOfGallery: gallery,
      phone: phone,
      bio: 'Write your bio...',
      image:
          'https://lh3.googleusercontent.com/a/ACg8ocJfXFIkop7eOqMZIu1erFqEuTs8kWiLC_5oSOrZNl7u-R5M2HHW=s288-c-no',
      coverImage:
          'https://images.pexels.com/photos/33107538/pexels-photo-33107538.jpeg',
      uId: uId,
      isEmailVerified: isEmailVerified,
    );
    emit(CreateUserLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
          emit(CreateUserSuccessState());
        })
        .catchError((error) {
          print(error.toString());
          emit(CreateUserErrorState(error.toString()));
        });
  }

  void registerWithGoogle() async {
    emit(RegisterLoadingState());
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(InitRegisterState());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          createUserData(
            email: user.email ?? '',
            password: '',
            name: user.displayName ?? 'Google User',
            birthday: '',
            phone: '',
            uId: user.uid,
            isEmailVerified: true,
          );
        } else {
          CashHelper.savedData(key: 'uId', value: user.uid);
          emit(CreateUserSuccessState());
        }
      }
    } catch (error) {
      print(error.toString());
      emit(RegisterErrorState(error.toString()));
    }
  }

  void registerWithFacebook() async {
    emit(RegisterLoadingState());
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            createUserData(
              email: user.email ?? '',
              password: '',
              name: user.displayName ?? 'Facebook User',
              birthday: '',
              phone: '',
              uId: user.uid,
              isEmailVerified: true,
            );
          } else {
            CashHelper.savedData(key: 'uId', value: user.uid);
            emit(CreateUserSuccessState());
          }
        }
      } else {
        emit(RegisterErrorState(result.message ?? 'Facebook Login Failed'));
      }
    } catch (error) {
      print(error.toString());
      emit(RegisterErrorState(error.toString()));
    }
  }
}
