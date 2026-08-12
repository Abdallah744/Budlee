abstract class LoginEvents {}

class LoginChangeVisibilityOneEvent extends LoginEvents {}

class LoginChangeVisibilityTwoEvent extends LoginEvents {}

class LoginChangeCheckedEvent extends LoginEvents {}

class UserLoginEvent extends LoginEvents {
  final String email;
  final String password;

  UserLoginEvent({required this.email, required this.password});
}

class LoginWithGoogleEvent extends LoginEvents {}

class LoginWithFacebookEvent extends LoginEvents {}
