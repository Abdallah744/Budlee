abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginChangeVisibilityState extends LoginStates {}

class LoginSuccessAppState extends LoginStates {
  final String uId;
  LoginSuccessAppState(this.uId);
}

class LoginLoadingAppState extends LoginStates {}

class LoginErrorAppState extends LoginStates {
  final String error;
  LoginErrorAppState(this.error);
}

// class ProfileLoadingAppState extends LoginStates {}
//
// class ProfileSuccessAppState extends LoginStates {}
//
// class ProfileErrorAppState extends LoginStates {
//   final String error;
//   ProfileErrorAppState(this.error);
// }
//
// class EditProfileLoadingState extends LoginStates {}
//
// class EditProfileSuccessState extends LoginStates {}
//
// class EditProfileErrorState extends LoginStates {
//   final String error;
//   EditProfileErrorState(this.error);
// }
//
// class LogoutSAppState extends LoginStates {}
//
// class ResetPasswordLoadingState extends LoginStates {}
//
// class ResetPasswordSuccessState extends LoginStates {}
//
// class ResetPasswordErrorState extends LoginStates {
//   final String error;
//   ResetPasswordErrorState(this.error);
// }
