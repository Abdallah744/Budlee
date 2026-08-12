import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../models/users/user_model.dart';
import '../../../utils/shared/network/local/cash_helper.dart';
import 'login_event.dart';
import 'login_states.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  LoginBloc() : super(LoginInitialState()) {
    on<LoginChangeVisibilityOneEvent>((event, emit) {
      visibleOff = !visibleOff;
      redEye = !redEye;
      if (redEye) {
        redEyeIcon = const Icon(Icons.visibility);
      } else {
        redEyeIcon = const Icon(Icons.visibility_off);
      }
      emit(LoginChangeVisibilityState());
    });

    on<LoginChangeVisibilityTwoEvent>((event, emit) {
      visibleOff2 = !visibleOff2;
      redEye = !redEye;
      if (redEye) {
        redEyeIcon2 = const Icon(Icons.visibility);
      } else {
        redEyeIcon2 = const Icon(Icons.visibility_off);
      }
      emit(LoginChangeVisibilityState());
    });

    on<LoginChangeCheckedEvent>((event, emit) {
      checked = !checked;
      emit(LoginChangeVisibilityState());
    });

    on<UserLoginEvent>((event, emit) async {
      emit(LoginLoadingAppState());
      try {
        final value = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password,
        );
        print(value.user!.email);
        print(value.user!.uid);
        CashHelper.savedData(key: 'uId', value: value.user!.uid);
        emit(LoginSuccessAppState(value.user!.uid));
      } catch (error) {
        emit(LoginErrorAppState(error.toString()));
      }
    });

    on<LoginWithGoogleEvent>((event, emit) async {
      emit(LoginLoadingAppState());
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          emit(LoginInitialState());
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          var userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await createUserData(
              uId: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? 'Google User',
              image: user.photoURL ?? '',
            );
          }

          CashHelper.savedData(key: 'uId', value: user.uid);
          emit(LoginSuccessAppState(user.uid));
        }
      } catch (error) {
        print(error.toString());
        emit(LoginErrorAppState(error.toString()));
      }
    });

    on<LoginWithFacebookEvent>((event, emit) async {
      emit(LoginLoadingAppState());
      try {
        final LoginResult result = await FacebookAuth.instance.login();

        if (result.status == LoginStatus.success) {
          final AuthCredential credential = FacebookAuthProvider.credential(
            result.accessToken!.tokenString,
          );

          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          User? user = userCredential.user;

          if (user != null) {
            var userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (!userDoc.exists) {
              await createUserData(
                uId: user.uid,
                email: user.email ?? '',
                name: user.displayName ?? 'Facebook User',
                image: user.photoURL ?? '',
              );
            }

            CashHelper.savedData(key: 'uId', value: user.uid);
            emit(LoginSuccessAppState(user.uid));
          }
        } else {
          emit(LoginErrorAppState(result.message ?? 'Facebook Login Failed'));
        }
      } catch (error) {
        print(error.toString());
        emit(LoginErrorAppState(error.toString()));
      }
    });
  }

  static LoginBloc get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  var redEye = false;
  var checked = false;
  Icon redEyeIcon = const Icon(Icons.visibility_off);
  bool visibleOff = true;
  var redEye2 = false;
  Icon redEyeIcon2 = const Icon(Icons.visibility_off);
  bool visibleOff2 = true;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var nameController = TextEditingController();
  var addressController = TextEditingController();
  var phonController = TextEditingController();
  var avatarController = TextEditingController();
  var genderController = TextEditingController();
  var birthdayController = TextEditingController();

  Map<String, dynamic> userProfileData = {};

  Future<void> createUserData({
    required String uId,
    required String email,
    required String name,
    String? image,
  }) async {
    userModel model = userModel(
      uId: uId,
      email: email,
      name: name,
      image:
          image ??
          'https://lh3.googleusercontent.com/a/ACg8ocJfXFIkop7eOqMZIu1erFqEuTs8kWiLC_5oSOrZNl7u-R5M2HHW=s288-c-no',
      isEmailVerified: true,
      bio: 'Write your bio...',
      birthday: '',
      phone: '',
      coverImage:
          'https://images.pexels.com/photos/33107538/pexels-photo-33107538.jpeg',
    );

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap());
  }
}
