// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:budlee_app/config/user/login_and_register/register_screen.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/login/login_bloc.dart';
import '../../../config/cubit/login/login_event.dart';
import '../../../config/cubit/login/login_states.dart';
import '../../../core/styles/colors.dart';
import '../../../modules/layouts/home_layout/home_page.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginStates>(
      listener: (context, state) {
        if (state is LoginSuccessAppState) {
          showToast(text: 'Login Successfully', state: ToastStates.SUCCESS);
          navigateToAndFinish(context, HomeScreen());
        } else if (state is LoginErrorAppState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        var bloc = LoginBloc.get(context);
        return Scaffold(
          backgroundColor: Colors.purple[50],
          appBar: AppBar(
            title: const Text(
              'Easy Chat ;)',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.purple[50],
            elevation: 0,
          ),
          body: Form(
            key: bloc.formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 40,
                        color: defaultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Login now to meet your friends and family',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 35),
                    emailTextFormField(
                      controller: bloc.emailController,
                      type: TextInputType.emailAddress,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'email address must not be empty';
                        } else if (!value.contains('@')) {
                          return 'email address must be valid';
                        } else {
                          return null;
                        }
                      },
                      label: 'Email Address',
                      prefix: const Icon(Icons.email),
                    ),
                    const SizedBox(height: 15),
                    passwordTextFormField(
                      controller: bloc.passwordController,
                      type: TextInputType.visiblePassword,
                      isPassword: bloc.visibleOff,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'password must not be empty';
                        } else if (value.length < 6) {
                          return 'password must be at least 6 characters';
                        } else {
                          return null;
                        }
                      },
                      label: 'Password',
                      prefix: const Icon(Icons.lock),
                      suffixPressed: () {
                        bloc.add(LoginChangeVisibilityOneEvent());
                      },
                      suffix: bloc.redEyeIcon,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: bloc.checked,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) {
                            bloc.add(LoginChangeCheckedEvent());
                          },
                        ),
                        const Text('Remember Me', style: TextStyle(fontSize: 16.0)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Rest Password',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: defaultColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    ConditionalBuilder(
                      condition: state is! LoginLoadingAppState,
                      builder: (context) => defaultButton(
                        function: () {
                          if (bloc.formKey.currentState!.validate() &&
                              bloc.checked) {
                            bloc.add(UserLoginEvent(
                              email: bloc.emailController.text,
                              password: bloc.passwordController.text,
                            ));
                          }
                        },
                        text: 'Login',
                        background: secondaryColor,
                        radius: 25,
                      ),
                      fallback: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    ),

                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        TextButton(
                          onPressed: () {
                            navigateTo(context, RegisterScreen());
                          },
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                              color: defaultColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'OR LOGIN WITH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            bloc.add(LoginWithGoogleEvent());
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Image(
                              image: NetworkImage(
                                'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                              ),
                              width: 35,
                              height: 35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            bloc.add(LoginWithFacebookEvent());
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.facebook,
                              color: Colors.blue[900],
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
