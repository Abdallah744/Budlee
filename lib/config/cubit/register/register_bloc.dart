import 'dart:io';
import 'package:budlee_app/models/users/user_model.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'register_event.dart';
import 'register_states.dart';

class RegisterBloc extends Bloc<RegisterEvents, RegisterStates> {
  RegisterBloc() : super(InitRegisterState()) {
    on<RegisterChangeVisibilityOneEvent>((event, emit) {
      visibleOff = !visibleOff;
      redEye = !redEye;
      if (redEye) {
        redEyeIcon = const Icon(Icons.visibility);
      } else {
        redEyeIcon = const Icon(Icons.visibility_off);
      }
      emit(RegisterChangeVisibilityState());
    });

    on<RegisterChangeVisibilityTwoEvent>((event, emit) {
      visibleOff2 = !visibleOff2;
      redEye = !redEye;
      if (redEye) {
        redEyeIcon2 = const Icon(Icons.visibility);
      } else {
        redEyeIcon2 = const Icon(Icons.visibility_off);
      }
      emit(RegisterChangeVisibilityState());
    });

    on<RegisterChangeRightsCheckedEvent>((event, emit) {
      rightsChecked = !rightsChecked;
      emit(RegisterChangeVisibilityState());
    });

    on<RegisterChangeTermsCheckedEvent>((event, emit) {
      termsChecked = !termsChecked;
      emit(RegisterChangeVisibilityState());
    });

    on<UserRegisterEvent>((event, emit) async {
      emit(RegisterLoadingState());
      try {
        final value = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password,
        );
        print(value.user!.email);
        print(value.user!.uid);
        await createUserData(
          email: event.email,
          password: event.password,
          name: event.name,
          bio: event.bio ?? 'Write your bio...',
          gallery: event.gallery ?? [],
          birthday: event.birthday,
          phone: event.phone,
          uId: value.user!.uid,
          isEmailVerified: false,
          emit: emit,
        );
      } catch (error) {
        emit(RegisterErrorState(error.toString()));
      }
    });

    on<RegisterWithGoogleEvent>((event, emit) async {
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
            await createUserData(
              email: user.email ?? '',
              password: '',
              name: user.displayName ?? 'Google User',
              birthday: '',
              phone: '',
              uId: user.uid,
              isEmailVerified: true,
              emit: emit,
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
    });

    on<RegisterWithFacebookEvent>((event, emit) async {
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
              await createUserData(
                email: user.email ?? '',
                password: '',
                name: user.displayName ?? 'Facebook User',
                birthday: '',
                phone: '',
                uId: user.uid,
                isEmailVerified: true,
                emit: emit,
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
    });
  }

  static RegisterBloc get(context) => BlocProvider.of(context);

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
  Icon redEyeIcon = const Icon(Icons.visibility_off);
  Icon redEyeIcon2 = const Icon(Icons.visibility_off);

  Future<void> createUserData({
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
    required Emitter<RegisterStates> emit,
  }) async {
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
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .set(model.toMap());
      emit(CreateUserSuccessState());
    } catch (error) {
      print(error.toString());
      emit(CreateUserErrorState(error.toString()));
    }
  }
}
