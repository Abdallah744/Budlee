// Ensure UserDataModel is imported from its central location:
// ignore_for_file: unused_local_va
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/shared/network/local/cash_helper.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  final formKey =
      GlobalKey<
        FormState
      >(); // Stores the access token// Holds the current user data
  var redEye = false;
  var checked = false;
  Icon redEyeIcon = Icon(Icons.visibility_off);
  bool visibleOff = true;
  var redEye2 = false;
  Icon redEyeIcon2 = Icon(Icons.visibility_off);
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

  Map<String, dynamic> userProfileData = {}; // Stores the user data>

  void changeVisibilityOne() {
    visibleOff = !visibleOff;
    redEye = !redEye;
    if (redEye) {
      redEyeIcon = Icon(Icons.visibility);
    } else {
      redEyeIcon = Icon(Icons.visibility_off);
    }
    emit(LoginChangeVisibilityState());
  }

  var uId;

  void changeVisibilityTwo() {
    visibleOff2 = !visibleOff2;
    redEye = !redEye;
    if (redEye) {
      redEyeIcon2 = Icon(Icons.visibility);
    } else {
      redEyeIcon2 = Icon(Icons.visibility_off);
    }
    emit(LoginChangeVisibilityState());
  }

  void changeChecked() {
    checked = !checked;
    emit(LoginChangeVisibilityState());
  }

  void userLogin(email, password) {
    emit(LoginLoadingAppState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.trim(), password: password)
        .then((value) {
          print(value.user!.email);
          print(value.user!.uid);
          CashHelper.savedData(key: 'uId', value: value.user!.uid);
          emit(LoginSuccessAppState(value.user!.uid));
        })
        .catchError((error) {
          emit(LoginErrorAppState(error.toString()));
        });
  }
}
