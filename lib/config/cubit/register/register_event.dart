import 'dart:io';

abstract class RegisterEvents {}

class RegisterChangeVisibilityOneEvent extends RegisterEvents {}

class RegisterChangeVisibilityTwoEvent extends RegisterEvents {}

class RegisterChangeRightsCheckedEvent extends RegisterEvents {}

class RegisterChangeTermsCheckedEvent extends RegisterEvents {}

class UserRegisterEvent extends RegisterEvents {
  final String email;
  final String password;
  final String name;
  final String? bio;
  final List<File>? gallery;
  final String birthday;
  final String phone;

  UserRegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    this.bio,
    this.gallery,
    required this.birthday,
    required this.phone,
  });
}

class RegisterWithGoogleEvent extends RegisterEvents {}

class RegisterWithFacebookEvent extends RegisterEvents {}
